"""
유저 시리얼라이저
회원가입, 로그인, 프로필 조회용
"""

from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """
    유저 정보 시리얼라이저 (조회용)
    """
    area_name = serializers.CharField(source='area.name', read_only=True, allow_null=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'nickname', 'name', 'first_name', 'last_name',
            'phone_number', 'profile_image',
            'role', 'party', 'is_verified', 'reputation',
            'area', 'area_name',
            'oauth_provider', 'oauth_id',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'created_at', 'updated_at',
            'oauth_provider', 'oauth_id',
            'reputation', 'is_verified'  # 시스템에서만 수정 가능
        ]


class RegisterSerializer(serializers.ModelSerializer):
    """
    회원가입 시리얼라이저
    """
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password]
    )
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = [
            'email', 'password', 'password2',
            'nickname', 'name',
            'phone_number', 'role'
        ]

    def validate(self, attrs):
        """비밀번호 확인 및 nickname 자동 생성"""
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({
                "password": "비밀번호가 일치하지 않습니다."
            })

        # nickname이 없으면 자동 생성
        if not attrs.get('nickname'):
            if attrs.get('name'):
                attrs['nickname'] = attrs['name']
            else:
                attrs['nickname'] = attrs['email'].split('@')[0][:50]

        return attrs

    def create(self, validated_data):
        """유저 생성"""
        validated_data.pop('password2')
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            nickname=validated_data.get('nickname', ''),
            name=validated_data.get('name', ''),
            phone_number=validated_data.get('phone_number', ''),
            role=validated_data.get('role', 'citizen')
        )
        return user


class SocialLoginSerializer(serializers.Serializer):
    """
    소셜 로그인 시리얼라이저 (Kakao)
    Frontend에서 받은 access_token을 검증
    """
    access_token = serializers.CharField(required=True)

    def validate_access_token(self, value):
        """Access token 검증"""
        if not value:
            raise serializers.ValidationError("Access token is required")
        return value
