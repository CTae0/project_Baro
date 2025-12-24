"""
개발 환경 설정 (Development Settings)
로컬 개발 시 사용
"""

from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# CORS - 개발 환경에서는 모든 origin 허용
CORS_ALLOW_ALL_ORIGINS = True

# Database - 개발 환경에서는 SQLite도 사용 가능 (PostGIS 테스트용)
# 필요시 아래 주석 해제
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.contrib.gis.db.backends.spatialite',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

# Email backend - 콘솔에 이메일 출력
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Django Debug Toolbar (선택사항)
# INSTALLED_APPS += ['debug_toolbar']
# MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
# INTERNAL_IPS = ['127.0.0.1']
