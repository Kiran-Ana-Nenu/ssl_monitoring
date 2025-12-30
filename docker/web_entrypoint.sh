#!/bin/sh
set -e

# Set default hosts/ports if not provided
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
RABBIT_HOST=${RABBIT_HOST:-rabbitmq}
RABBIT_PORT=${RABBIT_PORT:-5672}

echo "Installing netcat runtime dependency..."
apt-get update > /dev/null 2>&1 && apt-get install -y netcat-openbsd > /dev/null 2>&1

echo "Waiting for Postgres at $DB_HOST:$DB_PORT..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

echo "Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."
while ! nc -z $REDIS_HOST $REDIS_PORT; do
  sleep 1
done

echo "Waiting for RabbitMQ at $RABBIT_HOST:$RABBIT_PORT..."
while ! nc -z $RABBIT_HOST $RABBIT_PORT; do
  sleep 1
done

cd /app

echo "Running Django migrations..."
python /app/manage.py migrate --noinput

echo "Collecting static files..."
python /app/manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn ssl_monitor.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 3 \
  --timeout 120
