"""
유저 URL 라우팅
"""

from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from apps.users.views import RegisterView, CurrentUserView

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='login'),  # JWT
    path('auth/refresh/', TokenRefreshView.as_view(), name='refresh'),  # JWT
    path('auth/me/', CurrentUserView.as_view(), name='current_user'),
]
