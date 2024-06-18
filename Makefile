PORT ?= 8000

ifeq ($(shell command -v podman 2> /dev/null),)
    CMD=docker
else
    CMD=podman
endif

docker-run:
	$(CMD) build . -t mkdocs-learn-kubenet-docs
	$(CMD) run --rm --name learn-kubenet-docs -it -v "$$(pwd)":/docs -p ${PORT}:${PORT} --entrypoint ash mkdocs-learn-kubenet-docs:latest -c 'mkdocs serve -a 0.0.0.0:${PORT}'