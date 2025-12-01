import os
from celery import Celery
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ssl_monitor.settings")
app = Celery("ssl_monitor")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
