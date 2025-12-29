"""
Custom Adapters for django-allauth
이메일/비밀번호 회원가입과 소셜 로그인 처리를 위한 어댑터
"""
from allauth.account.adapter import DefaultAccountAdapter
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter


class CustomAccountAdapter(DefaultAccountAdapter):
    """이메일/비밀번호 회원가입 어댑터"""

    def save_user(self, request, user, form, commit=True):
        """회원가입 시 유저 정보 저장"""
        user = super().save_user(request, user, form, commit=False)
        data = form.cleaned_data
        user.first_name = data.get('first_name', '')
        user.last_name = data.get('last_name', '')
        if commit:
            user.save()
        return user


class CustomSocialAccountAdapter(DefaultSocialAccountAdapter):
    """소셜 로그인 어댑터 (Kakao)"""

    def pre_social_login(self, request, sociallogin):
        """
        소셜 로그인 전 처리
        이메일로 기존 계정 찾아서 연결
        """
        if not sociallogin.email_addresses:
            return

        email = sociallogin.email_addresses[0].email
        from django.contrib.auth import get_user_model
        User = get_user_model()

        try:
            user = User.objects.get(email=email)
            # 이미 존재하는 유저가 있으면 소셜 계정 연결
            sociallogin.connect(request, user)
        except User.DoesNotExist:
            # 새 유저는 그대로 진행
            pass

    def populate_user(self, request, sociallogin, data):
        """
        소셜 계정 정보로 유저 필드 채우기
        Kakao에서 받은 프로필 정보를 CustomUser 모델에 매핑
        """
        user = super().populate_user(request, sociallogin, data)

        provider = sociallogin.account.provider
        oauth_id = sociallogin.account.uid

        # OAuth provider와 id 저장
        user.oauth_provider = provider
        user.oauth_id = oauth_id

        # Kakao 프로필 정보 처리
        if provider == 'kakao':
            kakao_account = data.get('kakao_account', {})
            profile = kakao_account.get('profile', {})

            # 닉네임을 first_name으로 저장
            if profile.get('nickname'):
                user.first_name = profile['nickname']

        return user
