"""
페이징 클래스
Flutter 앱의 페이징 요구사항에 맞춤
"""

from rest_framework.pagination import PageNumberPagination


class StandardResultsSetPagination(PageNumberPagination):
    """
    표준 페이징 설정
    - 페이지당 20개 항목
    - 최대 100개까지 요청 가능
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
