"""
민원 URL 라우팅
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from apps.grievances.views import GrievanceViewSet, AreaViewSet

router = DefaultRouter()
router.register(r'areas', AreaViewSet, basename='area')
router.register(r'grievances', GrievanceViewSet, basename='grievance')

urlpatterns = [
    path('', include(router.urls)),
]
