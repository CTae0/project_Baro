"""
민원 시리얼라이저
Flutter 앱의 GrievanceModel과 정확히 매칭되는 JSON 형식 제공
"""

from rest_framework import serializers
from apps.grievances.models import Grievance, GrievanceImage, Like, Area, GrievanceSecret


class AreaSerializer(serializers.ModelSerializer):
    """행정동 시리얼라이저"""

    leader_name = serializers.CharField(source='leader.nickname', read_only=True, allow_null=True)
    grievance_count = serializers.IntegerField(read_only=True)  # ViewSet에서 annotate

    class Meta:
        model = Area
        fields = [
            'id', 'name', 'center_point',
            'leader', 'leader_name',
            'grievance_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class GrievanceImageSerializer(serializers.ModelSerializer):
    """
    민원 이미지 시리얼라이저
    """
    class Meta:
        model = GrievanceImage
        fields = ['id', 'image', 'order']


class GrievanceListSerializer(serializers.ModelSerializer):
    """
    민원 목록용 시리얼라이저
    - Flutter GrievanceModel과 정확히 매칭
    - snake_case JSON (like_count, is_liked, created_at 등)
    """
    like_count = serializers.IntegerField(read_only=True)  # ViewSet에서 annotate
    is_liked = serializers.SerializerMethodField()
    images = serializers.SerializerMethodField()
    user_id = serializers.CharField(source='user.id', read_only=True, allow_null=True)
    user_name = serializers.CharField(source='user.full_name', read_only=True, allow_null=True)

    # 새 필드
    area_id = serializers.IntegerField(source='area.id', read_only=True)
    area_name = serializers.CharField(source='area.name', read_only=True)
    is_accessible = serializers.SerializerMethodField()

    class Meta:
        model = Grievance
        fields = [
            'id', 'title', 'content', 'category', 'location',
            'latitude', 'longitude',
            'area_id', 'area_name',
            'status', 'visibility', 'is_accessible',
            'like_count', 'is_liked', 'images',
            'user_id', 'user_name',
            'created_at', 'updated_at', 'completed_at'
        ]

    def get_is_liked(self, obj):
        """현재 요청한 유저가 좋아요 했는지 확인"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.is_liked_by(request.user)
        return False

    def get_images(self, obj):
        """이미지 URL 목록 반환 (목록에서는 최대 5개)"""
        request = self.context.get('request')
        images = obj.images.all()[:5]
        if request:
            return [request.build_absolute_uri(img.image.url) for img in images]
        return [img.image.url for img in images]

    def get_is_accessible(self, obj):
        """
        비공개 민원 접근 가능 여부
        - 공개 민원: 항상 True
        - 비공개 민원: 작성자, 담당자, 인증된 정치인/관리자만 True
        """
        if obj.visibility == 'public':
            return True

        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return False

        user = request.user

        # 작성자 본인
        if obj.user == user:
            return True

        # 지역 담당자
        if hasattr(obj.area, 'leader') and obj.area.leader == user:
            return True

        # 인증된 정치인/관리자
        if user.role in ['admin', 'politician'] and user.is_verified:
            return True

        return False


class GrievanceDetailSerializer(GrievanceListSerializer):
    """
    민원 상세용 시리얼라이저
    목록과 동일하지만 모든 이미지 반환
    """
    def get_images(self, obj):
        """모든 이미지 URL 반환"""
        request = self.context.get('request')
        images = obj.images.all()
        if request:
            return [request.build_absolute_uri(img.image.url) for img in images]
        return [img.image.url for img in images]


class GrievanceCreateSerializer(serializers.ModelSerializer):
    """
    민원 생성용 시리얼라이저
    - Multipart 이미지 업로드 처리
    - 역지오코딩으로 위도/경도 → 지역명 변환
    - AreaMatcher로 area 자동 매칭
    """
    images = serializers.ListField(
        child=serializers.ImageField(max_length=1000000, allow_empty_file=False),
        write_only=True,
        required=False,
        max_length=10  # 최대 10개 이미지
    )

    # 비공개 민원용 패스워드
    password = serializers.CharField(
        write_only=True,
        required=False,
        min_length=4,
        max_length=50,
        help_text='비공개 민원일 경우 필수'
    )

    class Meta:
        model = Grievance
        fields = [
            'id', 'title', 'content', 'category',
            'latitude', 'longitude',
            'visibility', 'password',
            'images', 'status'
        ]
        read_only_fields = ['id', 'status']

    def validate_latitude(self, value):
        """위도 범위 검증 (-90 ~ 90)"""
        if not -90 <= value <= 90:
            raise serializers.ValidationError("위도는 -90에서 90 사이여야 합니다")
        return value

    def validate_longitude(self, value):
        """경도 범위 검증 (-180 ~ 180)"""
        if not -180 <= value <= 180:
            raise serializers.ValidationError("경도는 -180에서 180 사이여야 합니다")
        return value

    def validate_category(self, value):
        """카테고리 유효성 검증"""
        valid_categories = [choice[0] for choice in Grievance.CATEGORY_CHOICES]
        if value not in valid_categories:
            raise serializers.ValidationError(
                f"유효하지 않은 카테고리입니다. 가능한 값: {', '.join(valid_categories)}"
            )
        return value

    def validate(self, attrs):
        """비공개 민원은 패스워드 필수"""
        if attrs.get('visibility') == 'private' and not attrs.get('password'):
            raise serializers.ValidationError({
                'password': '비공개 민원은 패스워드가 필요합니다.'
            })
        return attrs

    def create(self, validated_data):
        """
        민원 생성 로직
        1. 이미지, 패스워드 데이터 분리
        2. 인증된 유저면 user 설정
        3. 역지오코딩으로 좌표 → 지역명 변환
        4. AreaMatcher로 area 매칭
        5. 민원 생성
        6. 이미지들 생성
        7. 비공개 민원이면 패스워드 생성
        """
        from apps.grievances.services import ReverseGeocoder, AreaMatcher

        images_data = validated_data.pop('images', [])
        password = validated_data.pop('password', None)
        request = self.context.get('request')

        # 유저 설정 (인증된 경우에만)
        if request and request.user.is_authenticated:
            validated_data['user'] = request.user

        # 역지오코딩 (좌표 → 지역명)
        lat = validated_data['latitude']
        lng = validated_data['longitude']
        geocoder = ReverseGeocoder()
        location_name = geocoder.get_location_name(lat, lng)
        validated_data['location'] = location_name

        # Area 매칭 (NEW)
        area_matcher = AreaMatcher()
        area = area_matcher.match_area(location_name, lat, lng)
        validated_data['area'] = area

        # 민원 생성
        grievance = Grievance.objects.create(**validated_data)

        # 이미지들 생성
        for idx, image_data in enumerate(images_data):
            GrievanceImage.objects.create(
                grievance=grievance,
                image=image_data,
                order=idx
            )

        # 비공개 민원 패스워드 생성 (NEW)
        if grievance.visibility == 'private' and password:
            secret = GrievanceSecret(grievance=grievance)
            secret.set_password(password)
            secret.save()

        return grievance
