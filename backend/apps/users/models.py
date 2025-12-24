"""
사용자 모델
이메일 기반 인증 시스템
"""

from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class CustomUserManager(BaseUserManager):
    """
    커스텀 유저 매니저
    이메일을 식별자로 사용
    """

    def create_user(self, email, password=None, **extra_fields):
        """일반 유저 생성"""
        if not email:
            raise ValueError('이메일은 필수입니다')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """슈퍼유저 생성"""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('슈퍼유저는 is_staff=True여야 합니다')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('슈퍼유저는 is_superuser=True여야 합니다')

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractUser):
    """
    커스텀 유저 모델
    username 대신 email을 식별자로 사용
    """

    # username 필드 제거
    username = None

    # 이메일을 고유 식별자로 사용
    email = models.EmailField('이메일', unique=True, db_index=True)

    # 추가 필드
    phone_number = models.CharField('전화번호', max_length=15, blank=True)
    profile_image = models.ImageField(
        '프로필 이미지',
        upload_to='users/profiles/',
        blank=True,
        null=True
    )

    # OAuth 소셜 로그인 지원 (카카오, 네이버)
    oauth_provider = models.CharField(
        'OAuth 제공자',
        max_length=20,
        blank=True,
        null=True,
        choices=[
            ('kakao', 'Kakao'),
            ('naver', 'Naver'),
        ]
    )
    oauth_id = models.CharField('OAuth ID', max_length=100, blank=True, null=True)

    # 타임스탬프
    created_at = models.DateTimeField('생성일', auto_now_add=True)
    updated_at = models.DateTimeField('수정일', auto_now=True)

    # 커스텀 매니저 사용
    objects = CustomUserManager()

    # 이메일을 인증 식별자로 사용
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    class Meta:
        db_table = 'users'
        verbose_name = '사용자'
        verbose_name_plural = '사용자'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['oauth_provider', 'oauth_id']),
        ]

    def __str__(self):
        return self.email

    @property
    def full_name(self):
        """전체 이름 반환"""
        if self.first_name and self.last_name:
            return f"{self.last_name}{self.first_name}"
        return self.email
