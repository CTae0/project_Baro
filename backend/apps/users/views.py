"""
유저 인증 뷰
"""

import requests
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model

from apps.users.serializers import RegisterSerializer, UserSerializer, SocialLoginSerializer

User = get_user_model()


class RegisterView(APIView):
    """
    회원가입 API
    POST /api/auth/register/
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'message': '회원가입이 완료되었습니다',
                'user': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CurrentUserView(APIView):
    """
    현재 로그인한 유저 정보 조회
    GET /api/auth/me/
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)


class KakaoLoginView(APIView):
    """
    Kakao OAuth 로그인 (Mobile Flow)
    POST /api/auth/kakao/

    Request Body:
    {
        "access_token": "kakao_access_token_from_sdk"
    }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import logging
        logger = logging.getLogger(__name__)

        logger.info("=== Kakao 로그인 요청 수신 ===")

        serializer = SocialLoginSerializer(data=request.data)
        if not serializer.is_valid():
            logger.error(f"Serializer 검증 실패: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        kakao_access_token = serializer.validated_data['access_token']
        logger.info(f"Kakao access_token 길이: {len(kakao_access_token)}")
        logger.debug(f"Kakao access_token 시작: {kakao_access_token[:20]}...")

        # Kakao API로 사용자 정보 조회
        try:
            logger.info("Kakao API 호출 시작...")
            user_info = self._get_kakao_user_info(kakao_access_token)
            logger.info(f"Kakao API 호출 성공 - 사용자 ID: {user_info.get('id')}")
        except Exception as e:
            logger.error(f"Kakao API 호출 실패: {str(e)}")
            return Response(
                {'error': 'Kakao API 호출 실패', 'detail': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 사용자 생성 또는 조회
        kakao_id = str(user_info['id'])
        kakao_account = user_info.get('kakao_account', {})
        profile = kakao_account.get('profile', {})
        email = kakao_account.get('email')

        logger.info(f"사용자 정보 - Kakao ID: {kakao_id}, Email: {email}")

        user, created = User.objects.get_or_create(
            oauth_provider='kakao',
            oauth_id=kakao_id,
            defaults={
                'email': email or f'kakao_{kakao_id}@baro.app',
                'first_name': profile.get('nickname', ''),
                'last_name': '',
            }
        )

        logger.info(f"사용자 {'생성' if created else '조회'} 완료 - User ID: {user.id}, Email: {user.email}")

        # JWT 토큰 생성
        refresh = RefreshToken.for_user(user)
        logger.info("JWT 토큰 생성 완료")

        return Response({
            'message': '카카오 로그인 성공',
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            },
            'is_new_user': created,
        })

    def _get_kakao_user_info(self, access_token):
        """Kakao API로 사용자 정보 조회"""
        import logging
        logger = logging.getLogger(__name__)

        url = 'https://kapi.kakao.com/v2/user/me'
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
        }

        logger.info(f"Kakao API 요청 - URL: {url}")
        logger.debug(f"Authorization 헤더: Bearer {access_token[:20]}...")

        response = requests.get(url, headers=headers, timeout=10)

        logger.info(f"Kakao API 응답 - Status: {response.status_code}")

        if response.status_code != 200:
            logger.error(f"Kakao API 에러 응답: {response.text}")
            raise Exception(f'Kakao API Error: {response.text}')

        logger.debug(f"Kakao API 응답 데이터: {response.text[:200]}...")
        return response.json()


class NaverLoginView(APIView):
    """
    Naver OAuth 로그인 (Mobile Flow)
    POST /api/auth/naver/

    Request Body:
    {
        "access_token": "naver_access_token_from_sdk"
    }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        import logging
        logger = logging.getLogger(__name__)

        logger.info("=== Naver 로그인 요청 수신 ===")

        serializer = SocialLoginSerializer(data=request.data)
        if not serializer.is_valid():
            logger.error(f"Serializer 검증 실패: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        naver_access_token = serializer.validated_data['access_token']
        logger.info(f"Naver access_token 길이: {len(naver_access_token)}")
        logger.debug(f"Naver access_token 시작: {naver_access_token[:20]}...")

        # Naver API로 사용자 정보 조회
        try:
            logger.info("Naver API 호출 시작...")
            user_info = self._get_naver_user_info(naver_access_token)
            logger.info(f"Naver API 호출 성공 - 사용자 ID: {user_info.get('response', {}).get('id')}")
        except Exception as e:
            logger.error(f"Naver API 호출 실패: {str(e)}")
            return Response(
                {'error': 'Naver API 호출 실패', 'detail': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 사용자 생성 또는 조회
        naver_response = user_info.get('response', {})
        naver_id = str(naver_response.get('id'))
        email = naver_response.get('email')
        name = naver_response.get('name')

        logger.info(f"사용자 정보 - Naver ID: {naver_id}, Email: {email}, Name: {name}")

        user, created = User.objects.get_or_create(
            oauth_provider='naver',
            oauth_id=naver_id,
            defaults={
                'email': email or f'naver_{naver_id}@baro.app',
                'first_name': name or '',
                'last_name': '',
            }
        )

        logger.info(f"사용자 {'생성' if created else '조회'} 완료 - User ID: {user.id}, Email: {user.email}")

        # JWT 토큰 생성
        refresh = RefreshToken.for_user(user)
        logger.info("JWT 토큰 생성 완료")

        return Response({
            'message': '네이버 로그인 성공',
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            },
            'is_new_user': created,
        })

    def _get_naver_user_info(self, access_token):
        """Naver API로 사용자 정보 조회"""
        import logging
        logger = logging.getLogger(__name__)

        url = 'https://openapi.naver.com/v1/nid/me'
        headers = {
            'Authorization': f'Bearer {access_token}'
        }

        logger.info(f"Naver API 요청 - URL: {url}")
        logger.debug(f"Authorization 헤더: Bearer {access_token[:20]}...")

        response = requests.get(url, headers=headers, timeout=10)

        logger.info(f"Naver API 응답 - Status: {response.status_code}")

        if response.status_code != 200:
            logger.error(f"Naver API 에러 응답: {response.text}")
            raise Exception(f'Naver API Error: {response.text}')

        logger.debug(f"Naver API 응답 데이터: {response.text[:200]}...")
        return response.json()


class LogoutView(APIView):
    """
    로그아웃 (토큰 블랙리스트)
    POST /api/auth/logout/

    Request Body:
    {
        "refresh": "refresh_token"
    }
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response({'message': '로그아웃 되었습니다'})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
