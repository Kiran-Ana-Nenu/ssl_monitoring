FROM nginx:stable-alpine

# Copy custom nginx config
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy static files collected from Django
# Make sure staticfiles folder exists in the build context
COPY docker/staticfiles/ /var/www/static

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
