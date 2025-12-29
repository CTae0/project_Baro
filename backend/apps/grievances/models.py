"""
민원(Grievance) 모델
시민 민원 신고 및 관리
"""

import uuid
from django.db import models
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.geos import Point
from django.core.validators import FileExtensionValidator
from apps.users.models import CustomUser


class Area(models.Model):
    """
    행정동 구역 모델
    정치인/관리자를 특정 구역에 배정하고 민원을 구역별로 분류
    """

    # PK uses BigAutoField (Django 기본값)
    id = models.BigAutoField(primary_key=True)

    name = models.CharField('행정동 이름', max_length=100, unique=True, db_index=True)

    # 중심 좌표 (지도 표시 및 근접 검색용)
    center_point = gis_models.PointField(
        '중심 좌표',
        geography=True,
        srid=4326
    )

    # 담당자 (정치인 또는 관리자)
    leader = models.ForeignKey(
        'users.CustomUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='led_areas',
        verbose_name='담당자',
        help_text='이 지역을 담당하는 정치인 또는 관리자'
    )

    # 선택적 경계 폴리곤 (자동 구역 판정용)
    boundary = gis_models.MultiPolygonField(
        '경계선',
        geography=True,
        srid=4326,
        null=True,
        blank=True
    )

    created_at = models.DateTimeField('생성일', auto_now_add=True)
    updated_at = models.DateTimeField('수정일', auto_now=True)

    class Meta:
        db_table = 'areas'
        verbose_name = '행정동'
        verbose_name_plural = '행정동'
        ordering = ['name']
        indexes = [
            models.Index(fields=['name']),
        ]

    def __str__(self):
        return self.name


class Grievance(models.Model):
    """
    민원 메인 모델
    PostGIS를 사용한 지리 데이터 지원
    """

    STATUS_CHOICES = [
        ('pending', '대기중'),
        ('in_progress', '처리중'),
        ('resolved', '완료'),
        # 마이그레이션 후 다음으로 변경 예정:
        # ('Pending', '대기중'),
        # ('Processing', '처리중'),
        # ('Completed', '완료'),
        # ('Rejected', '반려'),
    ]

    VISIBILITY_CHOICES = [
        ('public', '공개'),
        ('private', '비공개'),
    ]

    CATEGORY_CHOICES = [
        ('traffic', '교통/주차'),
        ('env', '환경/위생'),
        ('safety', '안전/치안'),
        ('facility', '공원/시설'),
        ('animal', '동물'),
        ('admin', '일반행정'),
        ('etc', '기타'),
    ]

    # 기본 정보
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='grievances',
        verbose_name='작성자'
    )

    # 내용
    title = models.CharField('제목', max_length=200, db_index=True)
    content = models.TextField('내용')
    category = models.CharField(
        '카테고리',
        max_length=20,
        choices=CATEGORY_CHOICES,
        default='etc',
        db_index=True
    )
    status = models.CharField(
        '상태',
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        db_index=True
    )

    # 공개 범위
    visibility = models.CharField(
        '공개 범위',
        max_length=20,
        choices=VISIBILITY_CHOICES,
        default='public',
        db_index=True
    )

    # 발생 지역 (행정동)
    # Note: 마이그레이션에서 null=True로 시작, 데이터 채운 후 NOT NULL로 변경
    area = models.ForeignKey(
        Area,
        on_delete=models.PROTECT,
        related_name='grievances',
        verbose_name='발생 지역',
        null=True,
        blank=True
    )

    # 위치 정보
    location = models.CharField('지역', max_length=200, blank=True)  # "강남구" 등
    latitude = models.FloatField('위도')
    longitude = models.FloatField('경도')
    point = gis_models.PointField('좌표', geography=True, srid=4326, null=True, blank=True)

    # 타임스탬프
    created_at = models.DateTimeField('생성일', auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField('수정일', auto_now=True)
    completed_at = models.DateTimeField(
        '완료 시각',
        null=True,
        blank=True,
        help_text='민원 처리 완료 시각'
    )

    class Meta:
        db_table = 'grievances'
        verbose_name = '민원'
        verbose_name_plural = '민원'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['status']),
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['visibility']),
            models.Index(fields=['area', '-created_at']),
        ]

    def __str__(self):
        return f"[{self.get_category_display()}] {self.title} ({self.location})"

    def save(self, *args, **kwargs):
        """저장 시 Point 객체 자동 생성"""
        if self.latitude and self.longitude and not self.point:
            self.point = Point(self.longitude, self.latitude, srid=4326)
        super().save(*args, **kwargs)

    def get_like_count(self):
        """좋아요 개수 (annotate 미사용 시에만 호출)"""
        return self.likes.count()

    def is_liked_by(self, user):
        """특정 유저가 좋아요 했는지 확인"""
        if not user or not user.is_authenticated:
            return False
        return self.likes.filter(user=user).exists()


class GrievanceImage(models.Model):
    """
    민원 이미지
    하나의 민원에 여러 이미지 첨부 가능
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    grievance = models.ForeignKey(
        Grievance,
        on_delete=models.CASCADE,
        related_name='images',
        verbose_name='민원'
    )
    image = models.ImageField(
        '이미지',
        upload_to='grievances/images/%Y/%m/%d/',
        validators=[
            FileExtensionValidator(
                allowed_extensions=['jpg', 'jpeg', 'png', 'webp']
            )
        ]
    )
    order = models.PositiveSmallIntegerField('순서', default=0)
    created_at = models.DateTimeField('생성일', auto_now_add=True)

    class Meta:
        db_table = 'grievance_images'
        verbose_name = '민원 이미지'
        verbose_name_plural = '민원 이미지'
        ordering = ['order', 'created_at']

    def __str__(self):
        return f"{self.grievance.title}의 이미지 {self.order + 1}"


class Like(models.Model):
    """
    좋아요
    한 유저가 한 민원에 한 번만 좋아요 가능
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='likes',
        verbose_name='사용자'
    )
    grievance = models.ForeignKey(
        Grievance,
        on_delete=models.CASCADE,
        related_name='likes',
        verbose_name='민원'
    )
    created_at = models.DateTimeField('생성일', auto_now_add=True)

    class Meta:
        db_table = 'likes'
        verbose_name = '좋아요'
        verbose_name_plural = '좋아요'
        unique_together = [('user', 'grievance')]
        indexes = [
            models.Index(fields=['user', 'grievance']),
            models.Index(fields=['grievance', '-created_at']),
        ]

    def __str__(self):
        return f"{self.user.email}님이 {self.grievance.title}에 좋아요"


class GrievanceSecret(models.Model):
    """
    비공개 민원 접근 패스워드
    visibility='private'인 민원에만 존재
    """

    grievance = models.OneToOneField(
        Grievance,
        on_delete=models.CASCADE,
        primary_key=True,
        related_name='secret',
        verbose_name='민원'
    )

    password_hash = models.CharField(
        '패스워드 해시',
        max_length=255,
        help_text='평문 저장 금지 - 해시만 저장'
    )

    created_at = models.DateTimeField('생성일', auto_now_add=True)

    class Meta:
        db_table = 'grievance_secrets'
        verbose_name = '비공개 민원 패스워드'
        verbose_name_plural = '비공개 민원 패스워드'

    def __str__(self):
        return f"{self.grievance.title}의 비공개 패스워드"

    def set_password(self, raw_password):
        """패스워드 해시 생성"""
        from django.contrib.auth.hashers import make_password
        self.password_hash = make_password(raw_password)

    def check_password(self, raw_password):
        """패스워드 검증"""
        from django.contrib.auth.hashers import check_password
        return check_password(raw_password, self.password_hash)
