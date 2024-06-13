PORT ?= 8000

docker-run:
	docker build . -t mkdocs-learn-kubenet-docs
	docker run --rm --name learn-kubenet-docs -v "$$(pwd)":/docs -p ${PORT}:${PORT} --entrypoint ash mkdocs-learn-kubenet-docs:latest -c 'mkdocs serve -a 0.0.0.0:${PORT}'