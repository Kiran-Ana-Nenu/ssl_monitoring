FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY src /app/src
COPY docker/web_entrypoint.sh /app/web_entrypoint.sh
RUN chmod +x /app/web_entrypoint.sh
WORKDIR /app/src
ENV PYTHONPATH=/app/src
ENV DJANGO_SETTINGS_MODULE=ssl_monitor.settings
ENTRYPOINT ["/app/web_entrypoint.sh"]
CMD ["gunicorn", "ssl_monitor.wsgi:application", "--bind", "0.0.0.0:8000"]
