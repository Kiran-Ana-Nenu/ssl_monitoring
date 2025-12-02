FROM nginx:stable-alpine

# Security Patch: update Alpine packages
RUN apk update && apk upgrade --no-cache

# Create non-root user
RUN adduser -D -H -u 1000 nginxuser

# Copy custom nginx config
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY docker/staticfiles/ /var/www/static

# Permissions for non-root user
RUN chown -R nginxuser:nginxuser /var/www/static /var/cache/nginx /etc/nginx

USER nginxuser

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
