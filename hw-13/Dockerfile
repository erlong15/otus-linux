FROM alpine:3.9.4
RUN apk add  nginx
RUN mkdir -p /run/nginx/ \
    && mkdir /www \
    && chown -R nginx:nginx /www
COPY nginx.conf /etc/nginx
COPY index.html /www
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
