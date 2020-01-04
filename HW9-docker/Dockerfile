FROM alpine:latest

# installing nginx
RUN apk update && apk add nginx
RUN mkdir -p /run/nginx

#copying config file to avoid 404 page
COPY ./default.conf /etc/nginx/conf.d/

# copy custom index.html
COPY ./index.html /var/lib/nginx/html/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]



