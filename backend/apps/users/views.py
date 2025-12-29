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
        serializer = SocialLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        kakao_access_token = serializer.validated_data['access_token']

        # Kakao API로 사용자 정보 조회
        try:
            user_info = self._get_kakao_user_info(kakao_access_token)
        except Exception as e:
            return Response(
                {'error': 'Kakao API 호출 실패', 'detail': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 사용자 생성 또는 조회
        kakao_id = str(user_info['id'])
        kakao_account = user_info.get('kakao_account', {})
        profile = kakao_account.get('profile', {})
        email = kakao_account.get('email')

        user, created = User.objects.get_or_create(
            oauth_provider='kakao',
            oauth_id=kakao_id,
            defaults={
                'email': email or f'kakao_{kakao_id}@baro.app',
                'first_name': profile.get('nickname', ''),
                'last_name': '',
            }
        )

        # JWT 토큰 생성
        refresh = RefreshToken.for_user(user)

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
        url = 'https://kapi.kakao.com/v2/user/me'
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
        }
        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            raise Exception(f'Kakao API Error: {response.text}')
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
