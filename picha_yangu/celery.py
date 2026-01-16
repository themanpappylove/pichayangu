import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'picha_yangu.settings')

app = Celery('picha_yangu')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
