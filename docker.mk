.PHONY: build
build:: ##@Docker Build an image

.PHONY: ship
ship:: ##@Docker Ship the image (build, ship)

.PHONY: run
run:: ##@Docker Run a container (build, run attached)

.PHONY: start
start:: ##@Docker Run a container (build, run detached)

.PHONY: stop
stop:: ##@Docker Stop the running container

.PHONY: clean
clean:: ##@Docker Remove the container

.PHONY: release
release:: ##@Docker Build and Ship
