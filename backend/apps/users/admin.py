"""
유저 관리자 페이지
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from apps.users.models import CustomUser


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    """커스텀 유저 관리자"""
    list_display = ['email', 'nickname', 'full_name', 'role', 'is_verified', 'reputation', 'area', 'oauth_provider', 'is_staff', 'created_at']
    list_filter = ['is_staff', 'is_superuser', 'is_active', 'oauth_provider', 'role', 'is_verified', 'created_at']
    search_fields = ['email', 'nickname', 'first_name', 'last_name', 'phone_number']
    ordering = ['-created_at']

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('개인정보', {'fields': ('nickname', 'first_name', 'last_name', 'phone_number', 'profile_image')}),
        ('역할 및 지역', {'fields': ('role', 'party', 'is_verified', 'reputation', 'area')}),
        ('OAuth', {'fields': ('oauth_provider', 'oauth_id')}),
        ('권한', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('중요 날짜', {'fields': ('last_login', 'date_joined', 'created_at', 'updated_at')}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'nickname', 'first_name', 'last_name', 'role'),
        }),
    )

    readonly_fields = ['created_at', 'updated_at', 'date_joined']
