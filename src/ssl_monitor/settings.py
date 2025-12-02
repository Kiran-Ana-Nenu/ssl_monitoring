import os
from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'replace-this-secret')
DEBUG = os.getenv('DJANGO_DEBUG', '1') == '1'
ALLOWED_HOSTS = os.getenv('DJANGO_ALLOWED_HOSTS', 'localhost').split(',')
INSTALLED_APPS = [
    'django.contrib.admin','django.contrib.auth','django.contrib.contenttypes',
    'django.contrib.sessions','django.contrib.messages','django.contrib.staticfiles',
    'rest_framework','django_celery_beat',
    'monitoring','dashboard','notifications',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]
ROOT_URLCONF = 'ssl_monitor.urls'
TEMPLATES = [{'BACKEND':'django.template.backends.django.DjangoTemplates','DIRS':[BASE_DIR.parent / 'templates'],'APP_DIRS':True,'OPTIONS':{'context_processors':['django.template.context_processors.debug','django.template.context_processors.request','django.contrib.auth.context_processors.auth','django.contrib.messages.context_processors.messages'],},},]
WSGI_APPLICATION = 'ssl_monitor.wsgi.application'
DATABASES = {'default':{'ENGINE':'django.db.backends.postgresql','NAME':os.getenv('POSTGRES_DB','sslmon'),'USER':os.getenv('POSTGRES_USER','sslmonuser'),'PASSWORD':os.getenv('POSTGRES_PASSWORD','ChangeMeStrongPassword'),'HOST':os.getenv('POSTGRES_HOST','db'),'PORT':os.getenv('POSTGRES_PORT','5432'),}}
REDIS_URL = os.getenv('REDIS_URL', 'redis://redis:6379/0')
CACHES = {'default':{'BACKEND':'django.core.cache.backends.redis.RedisCache','LOCATION':REDIS_URL}}
CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'amqp://admin:AdminPassword123@rabbitmq:5672//')
CELERY_RESULT_BACKEND = os.getenv('CELERY_RESULT_BACKEND', 'redis://redis:6379/1')
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TASK_ROUTES = {
    'notifications.tasks.send_email_alert': {'queue': 'email'},
}
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR.parent / 'staticfiles'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EMAIL_BACKEND = os.getenv('DJANGO_EMAIL_BACKEND', 'django.core.mail.backends.console.EmailBackend')
