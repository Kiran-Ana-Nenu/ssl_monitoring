FROM python:3.11-slim
WORKDIR /app
COPY appcode/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY appcode/src /app/src
WORKDIR /app/src
ENV PYTHONPATH=/app/src
ENV DJANGO_SETTINGS_MODULE=ssl_monitor.settings
CMD ["celery", "-A", "ssl_monitor", "worker", "-Q", "email", "--loglevel=INFO"]
