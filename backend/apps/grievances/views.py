"""
민원 ViewSet 및 API 뷰
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.db.models import Count, Prefetch
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter

from apps.grievances.models import Grievance, GrievanceImage, Like, Area, GrievanceSecret
from apps.grievances.serializers import (
    GrievanceListSerializer,
    GrievanceDetailSerializer,
    GrievanceCreateSerializer,
    AreaSerializer
)
from apps.grievances.permissions import IsOwnerOrReadOnly
from apps.grievances.services import NearbyGrievanceService
from core.pagination import StandardResultsSetPagination


class AreaViewSet(viewsets.ReadOnlyModelViewSet):
    """
    행정동 ViewSet (읽기 전용)

    엔드포인트:
    - list: GET /api/areas/ - 행정동 목록
    - retrieve: GET /api/areas/{id}/ - 행정동 상세 (담당자, 민원 수 포함)
    """
    queryset = Area.objects.select_related('leader').annotate(
        grievance_count=Count('grievances')  # 민원 개수 계산
    ).order_by('name')

    serializer_class = AreaSerializer
    permission_classes = []  # 인증 없이 접근 가능
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name']
    ordering_fields = ['name', 'grievance_count', 'created_at']


class GrievanceViewSet(viewsets.ModelViewSet):
    """
    민원 CRUD ViewSet

    엔드포인트:
    - list: GET /api/grievances/ - 민원 목록 (페이징)
    - retrieve: GET /api/grievances/{id}/ - 민원 상세
    - create: POST /api/grievances/ - 민원 생성 (multipart)
    - update/partial_update: PUT/PATCH /api/grievances/{id}/ - 수정 (소유자만)
    - destroy: DELETE /api/grievances/{id}/ - 삭제 (소유자만)

    커스텀 액션:
    - like: PATCH /api/grievances/{id}/like/ - 좋아요 토글
    - nearby: GET /api/grievances/nearby/?lat=&lng=&radius= - 주변 민원
    """

    # 쿼리 최적화 (N+1 문제 방지)
    queryset = Grievance.objects.select_related('user', 'area').prefetch_related(
        Prefetch('images', queryset=GrievanceImage.objects.order_by('order'))
    ).annotate(
        like_count=Count('likes')  # 좋아요 개수 미리 계산
    )

    permission_classes = []  # 임시로 인증 비활성화 (테스트용)
    pagination_class = None  # 페이지네이션 임시 비활성화 (Flutter 테스트용)
    parser_classes = [MultiPartParser, FormParser, JSONParser]  # 모든 액션에서 multipart 지원
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'location', 'category', 'visibility', 'area']
    search_fields = ['title', 'content', 'location']  # 검색 가능 필드
    ordering_fields = ['created_at', 'updated_at', 'like_count']
    ordering = ['-created_at']  # 최신순 정렬

    def get_queryset(self):
        """
        비공개 민원 필터링
        - 공개 민원: 모두에게 노출
        - 비공개 민원: 작성자, 담당자, 인증된 정치인/관리자만 노출
        """
        queryset = super().get_queryset()
        user = self.request.user

        # 인증되지 않은 사용자: 공개 민원만
        if not user.is_authenticated:
            return queryset.filter(visibility='public')

        # 인증된 사용자: 공개 민원 + 접근 가능한 비공개 민원
        from django.db.models import Q

        accessible_private = Q(visibility='private') & (
            Q(user=user) |  # 작성자 본인
            Q(area__leader=user) |  # 지역 담당자
            (Q(user__role__in=['admin', 'politician']) & Q(user__is_verified=True))  # 인증된 정치인/관리자
        )

        return queryset.filter(Q(visibility='public') | accessible_private)

    def get_serializer_class(self):
        """액션별 시리얼라이저 선택"""
        if self.action == 'create':
            return GrievanceCreateSerializer
        elif self.action == 'retrieve':
            return GrievanceDetailSerializer
        return GrievanceListSerializer

    def create(self, request, *args, **kwargs):
        """
        민원 생성 후 GrievanceListSerializer로 응답 반환
        (Flutter가 기대하는 모든 필드 포함)
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        grievance = serializer.save()

        # 생성된 민원을 like_count와 함께 재조회 (기본 queryset 사용)
        grievance = self.get_queryset().get(pk=grievance.pk)

        # GrievanceListSerializer로 응답 생성
        response_serializer = GrievanceListSerializer(
            grievance,
            context={'request': request}
        )
        headers = self.get_success_headers(response_serializer.data)
        return Response(
            response_serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers
        )

    @action(detail=True, methods=['patch'], permission_classes=[IsAuthenticated])
    def like(self, request, pk=None):
        """
        좋아요 토글
        - 좋아요 안했으면 → 생성
        - 이미 했으면 → 삭제
        """
        grievance = self.get_object()
        user = request.user

        like_obj, created = Like.objects.get_or_create(
            user=user,
            grievance=grievance
        )

        if not created:
            # 이미 좋아요한 상태면 삭제
            like_obj.delete()
            is_liked = False
        else:
            is_liked = True

        # 업데이트된 민원 반환 (기본 queryset 사용하여 like_count 포함)
        grievance = self.get_queryset().get(pk=grievance.pk)

        serializer = self.get_serializer(grievance)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """
        주변 민원 검색
        Query params:
        - lat: 위도 (필수)
        - lng: 경도 (필수)
        - radius: 반경 (km, 기본 5)
        """
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        radius = float(request.query_params.get('radius', 5))

        if not lat or not lng:
            return Response(
                {'error': 'lat와 lng 파라미터가 필요합니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            lat = float(lat)
            lng = float(lng)
        except ValueError:
            return Response(
                {'error': 'lat와 lng는 숫자여야 합니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 주변 민원 검색
        nearby_service = NearbyGrievanceService()
        queryset = nearby_service.get_nearby_grievances(lat, lng, radius)

        # like_count annotate 추가
        queryset = queryset.annotate(like_count=Count('likes'))

        # 페이징 적용
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def verify_password(self, request, pk=None):
        """
        비공개 민원 패스워드 검증
        Request body: {"password": "1234"}
        Response: {"verified": true/false, "grievance": {...}} or {"verified": false}
        """
        grievance = self.get_object()

        # 공개 민원이면 패스워드 필요 없음
        if grievance.visibility == 'public':
            return Response(
                {'error': '공개 민원은 패스워드가 필요하지 않습니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 패스워드 확인
        password = request.data.get('password')
        if not password:
            return Response(
                {'error': 'password 필드가 필요합니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # GrievanceSecret 확인
        try:
            secret = grievance.secret
            is_valid = secret.check_password(password)

            if is_valid:
                # 패스워드 맞으면 민원 상세 반환
                serializer = GrievanceDetailSerializer(
                    grievance,
                    context={'request': request}
                )
                return Response({
                    'verified': True,
                    'grievance': serializer.data
                })
            else:
                return Response({'verified': False}, status=status.HTTP_401_UNAUTHORIZED)

        except GrievanceSecret.DoesNotExist:
            return Response(
                {'error': '패스워드가 설정되지 않은 민원입니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['patch'], permission_classes=[IsAuthenticated])
    def update_status(self, request, pk=None):
        """
        민원 상태 변경 (담당자/관리자 전용)
        Request body: {"status": "Processing", "completed_at": "2025-12-30T12:00:00Z"} (completed_at은 선택)
        Response: {"status": "Processing", "completed_at": null}

        권한:
        - 해당 지역 담당자 (area.leader)
        - 인증된 정치인/관리자 (role in ['politician', 'admin'] and is_verified=True)
        """
        grievance = self.get_object()
        user = request.user

        # 권한 확인
        is_area_leader = hasattr(grievance.area, 'leader') and grievance.area.leader == user
        is_verified_official = user.role in ['admin', 'politician'] and user.is_verified

        if not (is_area_leader or is_verified_official):
            return Response(
                {'error': '민원 상태를 변경할 권한이 없습니다'},
                status=status.HTTP_403_FORBIDDEN
            )

        # 상태 업데이트
        new_status = request.data.get('status')
        if not new_status:
            return Response(
                {'error': 'status 필드가 필요합니다'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 유효한 status인지 확인
        valid_statuses = [choice[0] for choice in Grievance.STATUS_CHOICES]
        if new_status not in valid_statuses:
            return Response(
                {'error': f'유효하지 않은 status입니다. 가능한 값: {", ".join(valid_statuses)}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        grievance.status = new_status

        # completed_at 업데이트 (선택)
        if 'completed_at' in request.data:
            grievance.completed_at = request.data['completed_at']
        elif new_status == 'Completed' and not grievance.completed_at:
            # Completed 상태로 변경 시 자동으로 현재 시각 설정
            from django.utils import timezone
            grievance.completed_at = timezone.now()

        grievance.save(update_fields=['status', 'completed_at'])

        return Response({
            'status': grievance.status,
            'completed_at': grievance.completed_at
        })
