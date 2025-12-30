#!/bin/sh
# docker/celery_mail_entrypoint.sh

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Celery mail worker..."

# Optional: wait for DB and RabbitMQ to be ready
# You can use wait-for-it or similar, or just sleep a few seconds
sleep 10

# Start the Celery worker for mail tasks
# -A your_project_name.celery: the Celery app instance
# -l info: log level
# -Q mail: listen to the 'mail' queue
celery -A ssl_monitor_project worker \
       -l info \
       -Q mail \
       --concurrency=1

# Keep the container alive if celery exits (optional)
tail -f /dev/null
