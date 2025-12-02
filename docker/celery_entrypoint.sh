#!/bin/sh

# Default DB host/port if not set in .env
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}

# Wait for Postgres
echo "Waiting for Postgres at $DB_HOST:$DB_PORT..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

# Wait for Redis
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
echo "Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."
while ! nc -z $REDIS_HOST $REDIS_PORT; do
  sleep 1
done

# Wait for RabbitMQ
RABBIT_HOST=${RABBIT_HOST:-rabbitmq}
RABBIT_PORT=${RABBIT_PORT:-5672}
echo "Waiting for RabbitMQ at $RABBIT_HOST:$RABBIT_PORT..."
while ! nc -z $RABBIT_HOST $RABBIT_PORT; do
  sleep 1
done

# Change to app directory if needed
cd /app/src

echo "Starting Celery worker..."
exec celery -A ssl_monitor worker -l info
