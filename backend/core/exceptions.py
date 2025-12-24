"""
커스텀 예외 핸들러
Flutter 앱이 기대하는 에러 형식으로 변환
"""

from rest_framework.views import exception_handler
from rest_framework.response import Response


def custom_exception_handler(exc, context):
    """
    Django REST Framework 예외를 커스텀 형식으로 변환

    에러 타입별 처리:
    - 400: ValidationFailure (유효성 검사 실패)
    - 401: AuthFailure (인증 실패)
    - 403: PermissionDenied (권한 거부)
    - 404: NotFound (리소스 없음)
    - 500+: ServerFailure (서버 오류)
    """
    response = exception_handler(exc, context)

    if response is not None:
        custom_response = {
            'error': True,
            'message': str(exc),
            'status_code': response.status_code
        }

        # 상세 에러 정보가 있으면 추가
        if hasattr(exc, 'detail'):
            custom_response['details'] = exc.detail

        response.data = custom_response

    return response
