"""
유저 URL 라우팅
"""

from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from apps.users.views import (
    RegisterView,
    CurrentUserView,
    KakaoLoginView,
    LogoutView
)

urlpatterns = [
    # 이메일/비밀번호 인증
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='login'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='refresh'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
    path('auth/me/', CurrentUserView.as_view(), name='current_user'),

    # Kakao OAuth
    path('auth/kakao/', KakaoLoginView.as_view(), name='kakao_login'),
]
