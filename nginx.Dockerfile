FROM openresty/openresty:alpine

COPY nginx/ /etc/nginx/

ENTRYPOINT openresty -c /etc/nginx/nginx.conf