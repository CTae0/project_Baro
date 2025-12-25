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


class Grievance(models.Model):
    """
    민원 메인 모델
    PostGIS를 사용한 지리 데이터 지원
    """

    STATUS_CHOICES = [
        ('pending', '대기중'),
        ('in_progress', '처리중'),
        ('resolved', '완료'),
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
    status = models.CharField(
        '상태',
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        db_index=True
    )

    # 위치 정보
    location = models.CharField('지역', max_length=200, blank=True)  # "강남구" 등
    latitude = models.FloatField('위도')
    longitude = models.FloatField('경도')
    point = gis_models.PointField('좌표', geography=True, srid=4326, null=True, blank=True)

    # 타임스탬프
    created_at = models.DateTimeField('생성일', auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField('수정일', auto_now=True)

    class Meta:
        db_table = 'grievances'
        verbose_name = '민원'
        verbose_name_plural = '민원'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at']),
            models.Index(fields=['status']),
            models.Index(fields=['user', '-created_at']),
        ]

    def __str__(self):
        return f"{self.title} ({self.location})"

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
