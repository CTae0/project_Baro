"""
민원 시리얼라이저
Flutter 앱의 GrievanceModel과 정확히 매칭되는 JSON 형식 제공
"""

from rest_framework import serializers
from apps.grievances.models import Grievance, GrievanceImage, Like


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

    class Meta:
        model = Grievance
        fields = [
            'id', 'title', 'content', 'location',
            'latitude', 'longitude', 'like_count', 'is_liked',
            'images', 'created_at', 'updated_at', 'status',
            'user_id', 'user_name'
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
    """
    images = serializers.ListField(
        child=serializers.ImageField(max_length=1000000, allow_empty_file=False),
        write_only=True,
        required=False,
        max_length=10  # 최대 10개 이미지
    )

    class Meta:
        model = Grievance
        fields = ['id', 'title', 'content', 'latitude', 'longitude', 'images', 'status']
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

    def create(self, validated_data):
        """
        민원 생성 로직
        1. 이미지 데이터 분리
        2. 인증된 유저면 user 설정
        3. 역지오코딩으로 좌표 → 지역명 변환
        4. 민원 생성
        5. 이미지들 생성
        """
        from apps.grievances.services import ReverseGeocoder

        images_data = validated_data.pop('images', [])
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

        # 민원 생성
        grievance = Grievance.objects.create(**validated_data)

        # 이미지들 생성
        for idx, image_data in enumerate(images_data):
            GrievanceImage.objects.create(
                grievance=grievance,
                image=image_data,
                order=idx
            )

        return grievance
