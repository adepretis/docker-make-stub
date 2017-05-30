# -----------------------------------------------------------------------------
# All things docker-compose
# -----------------------------------------------------------------------------
running_container := $(shell docker ps -a -f "name=foo" --format="{{.ID}}")

.PHONY: up
up:: ##@Compose Start from docker-compose.yml
	$(shell_env) docker-compose \
		-f docker-compose.yml \
		up \
		--build

.PHONY: rm
rm:: ##@Compose Clean docker-compose stack
	docker-compose \
		rm \
		--force

# use spaces and not tabs in ifneq/endif
ifneq ($(running_container),)
    docker rm -f $(running_container)
endif
