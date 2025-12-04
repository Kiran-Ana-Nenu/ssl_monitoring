# FROM python:3.11-slim
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --upgrade pip && pip install -r requirements.txt
# COPY src /app/src
# COPY docker/web_entrypoint.sh /app/web_entrypoint.sh
# RUN chmod +x /app/web_entrypoint.sh
# WORKDIR /app/src
# ENV PYTHONPATH=/app/src
# ENV DJANGO_SETTINGS_MODULE=ssl_monitor.settings
# ENTRYPOINT ["/app/web_entrypoint.sh"]
# CMD ["gunicorn", "ssl_monitor.wsgi:application", "--bind", "0.0.0.0:9000"]
# =======================
# 1) BUILDER STAGE
# =======================
# =======================
# 1) BUILDER STAGE
# =======================
# FROM python:3.11-slim AS builder

# # Install OS build deps for wheels
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential gcc libpq-dev && \
#     rm -rf /var/lib/apt/lists/*

# WORKDIR /app

# # Copy requirements and build wheels
# COPY requirements.txt .
# RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# # =======================
# # 2) FINAL STAGE
# # =======================
# FROM python:3.11-slim

# ENV PYTHONUNBUFFERED=1 \
#     PYTHONDONTWRITEBYTECODE=1

# WORKDIR /app

# # Install minimal runtime deps
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libpq5 curl netcat-openbsd && \
#     rm -rf /var/lib/apt/lists/*

# # Copy wheels from builder and install
# COPY --from=builder /wheels /wheels
# RUN pip install --no-cache /wheels/*

# # Copy project source
# COPY . .

# # Collect static files
# RUN python src/manage.py collectstatic --noinput

# # Expose Gunicorn port
# EXPOSE 8000

# # Default entrypoint: shell command to allow scripts
# ENTRYPOINT ["sh", "-c"]

# =======================
# 1) BUILDER STAGE
# =======================
# =======================
# 1) BUILDER STAGE
# =======================
###############################
# 1) BUILDER STAGE
###############################
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install Python + build dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv python3-dev \
        build-essential gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and build wheels
COPY requirements.txt .
RUN pip3 wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


###############################
# 2) RUNTIME STAGE
###############################
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install Python + runtime dependencies only (no compiler)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip \
        libpq5 curl netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies from built wheels
COPY --from=builder /wheels /wheels
RUN pip3 install --no-cache /wheels/*

# Copy project source
COPY . .

# Django static files
RUN python3 src/manage.py collectstatic --noinput

EXPOSE 8000

ENTRYPOINT ["sh", "-c"]
