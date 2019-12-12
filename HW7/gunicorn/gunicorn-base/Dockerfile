FROM alpine:latest
LABEL key="lalbrekht@gmail.com"

RUN apk add --update \
              ca-certificates \
              musl \
              build-base \
              python3 \
              python3-dev \
              bash \
              git \
              gfortran \
              lapack-dev \
              libxml2-dev \
              libxslt-dev \
              jpeg-dev \
              py-pip \
  && pip install --upgrade pip \
&& rm /var/cache/apk/*

RUN mkdir /app

COPY requirements.txt /app
WORKDIR /app

RUN pip install -r requirements.txt
