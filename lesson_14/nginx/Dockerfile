FROM alpine:3.12.0
LABEL maintainer="<Chudakov Aleksandr> chudo88@gmail.com"

RUN apk add --no-cache \
        nginx=1.18.0-r0 \
        tzdata \
        curl \
        ca-certificates \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /var/www/localhost/htdocs/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]