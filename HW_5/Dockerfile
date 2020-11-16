FROM centos:centos7

RUN yum install -y http://192.168.50.10/repo/nginx-1.18.0-1.el7.ngx.x86_64.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]