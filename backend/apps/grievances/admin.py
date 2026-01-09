"""
민원 관리자 페이지
"""

from django.contrib import admin
from django.contrib.gis.admin import GISModelAdmin
from django.utils.html import format_html
from django.db.models import Count
from apps.grievances.models import Grievance, GrievanceImage, Like, Area, GrievanceSecret


class GrievanceImageInline(admin.TabularInline):
    """민원 이미지 인라인 (민원 수정 시 이미지도 함께 편집)"""
    model = GrievanceImage
    extra = 1
    fields = ['image', 'order', 'image_preview']
    readonly_fields = ['image_preview']

    def image_preview(self, obj):
        """이미지 미리보기"""
        if obj.image:
            return format_html(
                '<img src="{}" style="max-width: 200px;" />',
                obj.image.url
            )
        return '-'
    image_preview.short_description = '미리보기'


@admin.register(Area)
class AreaAdmin(GISModelAdmin):
    """행정동 관리자 페이지"""
    list_display = ['name', 'leader', 'grievance_count', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name', 'leader__email', 'leader__nickname']
    readonly_fields = ['grievance_count', 'created_at', 'updated_at']

    fieldsets = (
        ('기본 정보', {
            'fields': ('name', 'leader')
        }),
        ('지리 정보', {
            'fields': ('center_point', 'boundary')
        }),
        ('통계', {
            'fields': ('grievance_count', 'created_at', 'updated_at')
        }),
    )

    def get_queryset(self, request):
        """N+1 쿼리 방지: 민원 개수를 annotate로 미리 계산"""
        queryset = super().get_queryset(request)
        return queryset.annotate(
            _grievance_count=Count('grievances', distinct=True)
        )

    def grievance_count(self, obj):
        """해당 지역의 민원 개수 (annotate 사용)"""
        return obj._grievance_count
    grievance_count.short_description = '민원 수'
    grievance_count.admin_order_field = '_grievance_count'  # 정렬 가능


@admin.register(Grievance)
class GrievanceAdmin(GISModelAdmin):
    """민원 관리자 페이지 (지도 위젯 포함)"""
    list_display = ['title', 'category', 'area', 'location', 'status', 'visibility', 'user_email', 'like_count_display', 'created_at', 'completed_at']
    list_filter = ['category', 'status', 'visibility', 'area', 'created_at']
    search_fields = ['title', 'content', 'location', 'user__email', 'area__name']
    inlines = [GrievanceImageInline]

    fieldsets = (
        ('기본 정보', {
            'fields': ('user', 'category', 'title', 'content', 'status', 'visibility', 'completed_at')
        }),
        ('위치', {
            'fields': ('area', 'location', 'latitude', 'longitude', 'point')
        }),
        ('메타', {
            'fields': ('like_count_display', 'created_at', 'updated_at')
        }),
    )

    readonly_fields = ['id', 'created_at', 'updated_at', 'like_count_display']

    def user_email(self, obj):
        return obj.user.email if obj.user else '익명'
    user_email.short_description = '작성자'

    def like_count_display(self, obj):
        return obj.like_count
    like_count_display.short_description = '좋아요'


@admin.register(GrievanceImage)
class GrievanceImageAdmin(admin.ModelAdmin):
    """민원 이미지 관리자"""
    list_display = ['grievance', 'order', 'image_preview', 'created_at']
    list_filter = ['created_at']
    search_fields = ['grievance__title']
    readonly_fields = ['image_preview']

    def image_preview(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="max-width: 200px;" />',
                obj.image.url
            )
        return '-'
    image_preview.short_description = '미리보기'


@admin.register(Like)
class LikeAdmin(admin.ModelAdmin):
    """좋아요 관리자"""
    list_display = ['user', 'grievance', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__email', 'grievance__title']
    readonly_fields = ['created_at']
