"""
민원 관련 서비스 레이어
- 역지오코딩 (Naver Map API)
- 주변 민원 검색 (PostGIS)
"""

import requests
import logging
from django.conf import settings
from django.core.cache import cache
from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from apps.grievances.models import Grievance, Area

logger = logging.getLogger(__name__)


class ReverseGeocoder:
    """
    좌표를 주소로 변환하는 서비스
    Naver Map Reverse Geocoding API 사용
    """

    def __init__(self):
        self.client_id = settings.NAVER_MAP_CLIENT_ID
        self.client_secret = settings.NAVER_MAP_CLIENT_SECRET
        self.api_url = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"

    def get_location_name(self, latitude, longitude):
        """
        위도/경도 → 지역명 변환
        한국 주소는 '구' 단위 반환 (예: 강남구, 서초구)

        Args:
            latitude: 위도
            longitude: 경도

        Returns:
            지역명 (예: "강남구", "서초구")
        """
        # 캐시 키 생성 (소수점 4자리까지)
        cache_key = f"naver_geocode_{latitude:.4f}_{longitude:.4f}"

        # 캐시 확인 (7일간 유지)
        cached_location = cache.get(cache_key)
        if cached_location:
            return cached_location

        try:
            # Naver Map API 요청
            headers = {
                'X-NCP-APIGW-API-KEY-ID': self.client_id,
                'X-NCP-APIGW-API-KEY': self.client_secret,
            }
            params = {
                'coords': f"{longitude},{latitude}",  # 경도,위도 순서 주의!
                'output': 'json',
                'orders': 'addr'  # 지번 주소 우선
            }

            response = requests.get(
                self.api_url,
                headers=headers,
                params=params,
                timeout=5
            )
            response.raise_for_status()

            data = response.json()

            # 응답 파싱
            if data.get('status', {}).get('code') == 0:
                results = data.get('results', [])
                if results:
                    region = results[0].get('region', {})

                    # 구 단위 주소 추출
                    # area1: 시/도, area2: 시/군/구, area3: 읍/면/동
                    area2 = region.get('area2', {}).get('name', '')  # 강남구
                    area3 = region.get('area3', {}).get('name', '')  # 역삼동

                    # "강남구" 형식으로 반환
                    location_name = area2 if area2 else area3

                    if location_name:
                        # 7일간 캐시 저장
                        cache.set(cache_key, location_name, 60 * 60 * 24 * 7)
                        return location_name

            logger.warning(f"네이버 지오코딩 결과 없음: ({latitude}, {longitude})")

        except requests.exceptions.RequestException as e:
            logger.error(f"네이버 지오코딩 API 오류: {e}")
        except Exception as e:
            logger.error(f"지오코딩 처리 오류: {e}")

        # 실패시 좌표 반환
        return f"{latitude:.4f}, {longitude:.4f}"


class NearbyGrievanceService:
    """PostGIS를 사용한 주변 민원 검색"""

    @staticmethod
    def get_nearby_grievances(latitude, longitude, radius_km=5):
        """
        특정 좌표 주변 민원 검색

        Args:
            latitude: 중심 위도
            longitude: 중심 경도
            radius_km: 검색 반경 (기본 5km)

        Returns:
            거리순으로 정렬된 민원 QuerySet
        """
        user_location = Point(longitude, latitude, srid=4326)

        # PostGIS 거리 계산 쿼리
        queryset = Grievance.objects.annotate(
            distance=Distance('point', user_location)
        ).filter(
            point__distance_lte=(user_location, radius_km * 1000)  # 미터 단위
        ).order_by('distance')

        return queryset


class AreaMatcher:
    """
    민원 위치를 행정동(Area)에 매칭하는 서비스
    """

    @staticmethod
    def match_area(location_name, latitude, longitude):
        """
        location_name (Naver 역지오코딩 결과)와 좌표를 기반으로 Area 찾기

        Args:
            location_name: "강남구", "서울 강남구" 등
            latitude: 위도
            longitude: 경도

        Returns:
            Area 인스턴스
        """
        # Strategy 1: Exact or partial name match
        if location_name:
            # Try exact match
            area = Area.objects.filter(name__iexact=location_name).first()
            if area:
                logger.info(f"Area matched by exact name: {area.name}")
                return area

            # Try partial match (e.g., "서울 강남구" contains "강남구")
            for area in Area.objects.exclude(name='미지정'):
                if area.name in location_name:
                    logger.info(f"Area matched by partial name: {area.name}")
                    return area

        # Strategy 2: Find nearest area by center_point
        point = Point(longitude, latitude, srid=4326)
        nearest_area = Area.objects.exclude(name='미지정').annotate(
            distance=Distance('center_point', point)
        ).order_by('distance').first()

        if nearest_area:
            logger.info(f"Area matched by proximity: {nearest_area.name}")
            return nearest_area

        # Strategy 3: Fallback to default
        logger.warning(f"No area match found for {location_name} ({latitude}, {longitude}), using default")
        return Area.objects.get(name='미지정')
