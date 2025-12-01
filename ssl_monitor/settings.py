import os
from pathlib import Path
from datetime import timedelta
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'replace-this-for-prod')
DEBUG = os.getenv('DJANGO_DEBUG', '1') == '1'
ALLOWED_HOSTS = ['*']
INSTALLED_APPS = [
    'django.contrib.admin','django.contrib.auth','django.contrib.contenttypes',
    'django.contrib.sessions','django.contrib.messages','django.contrib.staticfiles',
    'rest_framework','django_celery_beat',
    'monitoring','dashboard','notifications',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware','django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware','django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware','django.contrib.messages.middleware.MessageMiddleware',
]
ROOT_URLCONF = 'ssl_monitor.urls'
TEMPLATES = [{'BACKEND':'django.template.backends.django.DjangoTemplates','DIRS':[BASE_DIR / 'templates'],'APP_DIRS':True,'OPTIONS':{'context_processors':['django.template.context_processors.debug','django.template.context_processors.request','django.contrib.auth.context_processors.auth','django.contrib.messages.context_processors.messages'],},},]
WSGI_APPLICATION = 'ssl_monitor.wsgi.application'
DATABASES = {'default':{'ENGINE':'django.db.backends.postgresql','NAME':os.getenv('POSTGRES_DB','ssl_monitor'),'USER':os.getenv('POSTGRES_USER','postgres'),'PASSWORD':os.getenv('POSTGRES_PASSWORD','postgres'),'HOST':os.getenv('POSTGRES_HOST','db'),'PORT':os.getenv('POSTGRES_PORT','5432'),}}
REDIS_URL = os.getenv('REDIS_URL','redis://redis:6379/0')
CACHES = {'default':{'BACKEND':'django.core.cache.backends.redis.RedisCache','LOCATION':REDIS_URL}}
CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
AUTH_PASSWORD_VALIDATORS = []
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True
STATIC_URL = '/static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EMAIL_BACKEND = os.getenv('DJANGO_EMAIL_BACKEND','django.core.mail.backends.console.EmailBackend')
DEFAULT_FROM_EMAIL = 'noreply@ssl-monitor.local'
