init:
	# Первичная сборка
	docker build -t gunicorn-base gunicorn-base/
	docker build -t gunicorn .
	docker-compose up -d
	
rebuild:
	docker-compose kill
	docker-compose rm -f
	docker-compose up -d

pre-build:

post-build:

drop:
	docker-compose kill
	docker-compose rm -f

