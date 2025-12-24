"""
민원 권한 클래스
"""

from rest_framework.permissions import BasePermission, SAFE_METHODS


class IsOwnerOrReadOnly(BasePermission):
    """
    읽기는 누구나, 쓰기는 소유자만
    """

    def has_object_permission(self, request, view, obj):
        # 읽기 요청은 허용
        if request.method in SAFE_METHODS:
            return True

        # 쓰기는 소유자만 (익명 민원의 경우 수정 불가)
        return obj.user and obj.user == request.user
