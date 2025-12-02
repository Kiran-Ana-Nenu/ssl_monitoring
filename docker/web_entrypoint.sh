#!/bin/sh

# Set default hosts/ports if not set in .env
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
RABBIT_HOST=${RABBIT_HOST:-rabbitmq}
RABBIT_PORT=${RABBIT_PORT:-5672}

# Wait for Postgres
echo "Waiting for Postgres at $DB_HOST:$DB_PORT..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

# Wait for Redis
echo "Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."
while ! nc -z $REDIS_HOST $REDIS_PORT; do
  sleep 1
done

# Wait for RabbitMQ
echo "Waiting for RabbitMQ at $RABBIT_HOST:$RABBIT_PORT..."
while ! nc -z $RABBIT_HOST $RABBIT_PORT; do
  sleep 1
done

# Change to app directory
cd /app/src

# Run Django migrations
echo "Running Django migrations..."
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn ssl_monitor.wsgi:application --bind 0.0.0.0:8000
