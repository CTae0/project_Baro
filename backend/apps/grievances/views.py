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

from apps.grievances.models import Grievance, GrievanceImage, Like
from apps.grievances.serializers import (
    GrievanceListSerializer,
    GrievanceDetailSerializer,
    GrievanceCreateSerializer
)
from apps.grievances.permissions import IsOwnerOrReadOnly
from apps.grievances.services import NearbyGrievanceService
from core.pagination import StandardResultsSetPagination


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
    queryset = Grievance.objects.select_related('user').prefetch_related(
        Prefetch('images', queryset=GrievanceImage.objects.order_by('order'))
    ).annotate(
        like_count=Count('likes')  # 좋아요 개수 미리 계산
    )

    permission_classes = []  # 임시로 인증 비활성화 (테스트용)
    pagination_class = None  # 페이지네이션 임시 비활성화 (Flutter 테스트용)
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'location', 'category']
    search_fields = ['title', 'content', 'location']  # 검색 가능 필드
    ordering_fields = ['created_at', 'updated_at', 'like_count']
    ordering = ['-created_at']  # 최신순 정렬

    def get_serializer_class(self):
        """액션별 시리얼라이저 선택"""
        if self.action == 'create':
            return GrievanceCreateSerializer
        elif self.action == 'retrieve':
            return GrievanceDetailSerializer
        return GrievanceListSerializer

    def get_parsers(self):
        """생성 시 Multipart 파서 사용"""
        if hasattr(self, 'action') and self.action == 'create':
            return [MultiPartParser(), FormParser(), JSONParser()]
        return [JSONParser()]

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
