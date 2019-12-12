FROM gunicorn-base:latest
LABEL key="lalbrekht@gmail.com"

RUN pip install gunicorn

RUN pip install django

WORKDIR /app

COPY app /app

EXPOSE 8000

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD [ "gunicorn", "--bind", "0.0.0.0:8000", "myapp:app" ]
