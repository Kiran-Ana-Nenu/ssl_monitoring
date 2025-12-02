import os
from celery import Celery
from celery.schedules import crontab
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ssl_monitor.settings')
app = Celery('ssl_monitor')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
app.conf.beat_schedule = {
    'daily_check': {
        'task': 'monitoring.tasks.bulk_check_all_domains',
        'schedule': crontab(hour=2, minute=0),
    }
}
