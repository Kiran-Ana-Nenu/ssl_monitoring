FROM nginx:stable-alpine
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY staticfiles /var/www/static
