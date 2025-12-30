# src/ssl_monitor/settings.py

import os
from pathlib import Path

# -----------------------------------
# BASE PATHS
# -----------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = BASE_DIR.parent  # /opt/ssl_monitor_project/src -> /opt/ssl_monitor_project

# -----------------------------------
# SECURITY
# -----------------------------------
SECRET_KEY = os.getenv(
    "DJANGO_SECRET_KEY",
    "django-insecure-change-me-in-production"
)
DEBUG = True
DEBUG = os.getenv("DJANGO_DEBUG", "True") == "True"

ALLOWED_HOSTS = os.getenv("DJANGO_ALLOWED_HOSTS", "*").split(",")
ALLOWED_HOSTS = ["*", "localhost"]
# -----------------------------------
# APPLICATIONS
# -----------------------------------
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Local apps
    'dashboard',
    'monitoring',
    'notifications',
]

# -----------------------------------
# MIDDLEWARE
# -----------------------------------
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'ssl_monitor.urls'

# -----------------------------------
# TEMPLATES
# -----------------------------------
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            PROJECT_ROOT / 'templates',  # /opt/ssl_monitor_project/templates
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'ssl_monitor.wsgi.application'
ASGI_APPLICATION = 'ssl_monitor.asgi.application'

# -----------------------------------
# DATABASE
# -----------------------------------
DATABASES = {
    'default': {
        'ENGINE': os.getenv('DB_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.getenv(
            'DB_NAME',
            PROJECT_ROOT / 'db.sqlite3'
        ),
        'USER': os.getenv('DB_USER', ''),
        'PASSWORD': os.getenv('DB_PASSWORD', ''),
        'HOST': os.getenv('DB_HOST', ''),
        'PORT': os.getenv('DB_PORT', ''),
    }
}

# -----------------------------------
# PASSWORDS
# -----------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# -----------------------------------
# I18N
# -----------------------------------
LANGUAGE_CODE = 'en-us'
TIME_ZONE = os.getenv("DJANGO_TIME_ZONE", "UTC")
USE_I18N = True
USE_TZ = True

# -----------------------------------
# STATIC FILES
# -----------------------------------
# STATIC_URL = '/static/'
# STATIC_ROOT = PROJECT_ROOT / 'staticfiles'
# #STATICFILES_DIRS = []
# STATICFILES_DIRS = [PROJECT_ROOT / 'docker' / 'staticfiles'] 



PROJECT_ROOT = BASE_DIR.parent  # /app

STATIC_URL = '/static/'

# Source static files (existing ones for development)
STATICFILES_DIRS = [PROJECT_ROOT / 'docker' / 'staticfiles']  # matches /app/docker/staticfiles in container

# Destination for collectstatic (will be created automatically)
STATIC_ROOT = PROJECT_ROOT / 'static'  # /app/static



# -----------------------------------
# LOGIN / AUTH
# -----------------------------------
LOGIN_URL = '/login/'
LOGIN_REDIRECT_URL = '/'
LOGOUT_REDIRECT_URL = '/login/'

# -----------------------------------
# EMAIL (optional)
# -----------------------------------
EMAIL_BACKEND = os.getenv(
    "DJANGO_EMAIL_BACKEND",
    "django.core.mail.backends.console.EmailBackend" if DEBUG
    else "django.core.mail.backends.smtp.EmailBackend"
)

EMAIL_HOST = os.getenv("EMAIL_HOST", "localhost")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", 25))
EMAIL_HOST_USER = os.getenv("EMAIL_USER", "")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_PASSWORD", "")
EMAIL_USE_TLS = os.getenv("EMAIL_TLS", "False") == "True"

# -----------------------------------
# CELERY
# -----------------------------------
CELERY_BROKER_URL = os.getenv("CELERY_BROKER_URL", "redis://redis:6379/0")
CELERY_RESULT_BACKEND = os.getenv("CELERY_RESULT_BACKEND", "redis://redis:6379/1")

# -----------------------------------
# DEFAULT PK
# -----------------------------------
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
