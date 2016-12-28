# Docker Make Stub

The idea behind this project is to provide a generalized, (more or less) opinioated and convenient make/Makefile stub, focused on "All things Docker". It can be utilized by developers and maschines alike (e.g. TeamCity, Jenkins, GoCD, ...)

Except for the auto-generated ``help``, the stub does not implement any ``make``. Its purpose is to provide a common target-naming for different purposes, the means to easily define variables and a color-coded (``xterm-256``), auto-generated usage/help.

Currently available stubs:

  * docker.mk for ``docker``
  * docker-compose.mk for ``docker-compose``
  * rancher-compose.mk for ``rancher-compose``

## How to use it

### The Makefile

To make it work, the only thing you have to add at least the ``common.mk`` to your project/repository. Add other ``.mk`` files depending on your context (pure Docker, docker-compose, Rancher using rancher-compose) Next add add the following at the beginning of your ``Makefile``

```
# Include available stubs
include *.mk
```

Every ``.mk`` comes with an opinionated list of targets relevant for the corresponding context and a "default documentation". Targets that have been implemented in your ``Makefile`` are color-coded as **yellow (name)** and **green (documentation)**, all others are **displayed in red**.

### Implement stub targets

It is totally up to you how targets behave and what they do. To implement a target, add the following to your ``Makefile``:

```
.PHONY: target
target:: ##@MyCategory This is a description of what this target does.
	@echo "Yay!"
```

Valid target descriptions are:

  * \##@MyCategory\<space>Description
  * \##@My\<space>category\<space>rocks\<tab>Description

**Important**: You have to implement targets as [Double-Colon Rule](https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html) because the ``.mk`` files define it this way.

If the stub defines a target pre-categorized in e.g. ``Docker``, you can also override this in your own documentation:

```
run:: ##@Compose I want run in Compose not Docker
```

The ``make help`` auto-generation will detect this and display only one ``run`` categorized under ``Compose`` instead of both of them (one below ``Docker`` and one below ``Compose``)

### Variables and adding variables

When creating all this, the following requirements had been defined:

  * any (overrideable) variable relevant for any target's behaviour and its value should be automatically displayed in ``make help``
  * variables must be overrideable as you'd expect it from ``make`` using e.g.
    * ``make VAR=value mytarget``
    * ``VAR=value make mytarget`` or
    * ``export VAR=value; make mytarget``
  * all (and only) these variables should be able to pass to a sub-process, which can use them to interpolate them (e.g. in ``docker-compose.yml``)
  * internal ``make`` variables should not pollute the usage/help

### Defining variables

Do define a variable that suffices these criteria, add the following at the beginnging of your ``Makefile``

```
# Docker
$(eval $(call defw,NS,mydockerhub.mydomain.com/mynamespace))
$(eval $(call defw,REPO,myprojectrepo))
$(eval $(call defw,VERSION,latest))
```

Your CI (e.g. TeamCity) can then define a build-step like this:

```
make VERSION=build-%build.counter% deploy
```

### The special ``$(shell_env)``

In order to pass all your defined variables to a sub-process for further use in e.g. ``docker-compose.yml`` add the special variable ``$(shell_env)`` in front of your call:

```
$(eval $(call defw,MY_VAR1,value1))
$(eval $(call defw,MY_VAR2,value2))
...

.PHONY: deploy
deploy: ##@MyTargets this is a target
	$(shell_env) rancher-compose up -d
```

This results in ``rancher-compose up -d`` being called with

```
MY_VAR1="value1" MY_VAR2="value2" rancher-compose up -d
```

For an example see below.

#### Note

We already experimented with integrating [Hasicorp's Vault](https://www.vaultproject.io/) for variables that contain secrets which should not be stored in any VCS, for example:

```
$(deval $(call defw,RANCHER_ACCESS_KEY,$(call vault,rancher/api,.data.access_key)
$(deval $(call defw,RANCHER_SECRET_KEY,$(call vault,rancher/api,.data.secret_key)
```

This is still experimental and has not been added to this repository yet! It's documented here just to give you an idea of what could (should) be possible.

## Docker image

See https://hub.docker.com/r/25thfloor/docker-make-stub/ - documentation pending!

## Implementation examples

### docker

```Makefile
# Docker
$(eval $(call defw,NS,myhub.docker.example.com/mynamespace))
$(eval $(call defw,REPO,myrepo))
$(eval $(call defw,VERSION,latest))
$(eval $(call defw,NAME,my-run-name))

.PHONY: build
build:: ##@Docker Build an image
	docker build --pull -t $(NS)/$(REPO):$(VERSION) .

.PHONY: ship
ship:: ##@Docker Ship the image (build, ship)
ship:: build
	docker push $(NS)/$(REPO):$(VERSION)

.PHONY: run
run:: ##@Docker Run a container (build, run attached)
run:: build
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENVS) $(NS)/$(REPO):$(VERSION)

.PHONY: start
start:: ##@Docker Run a container (build, run detached)
start:: build start
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENVS) $(NS)/$(REPO):$(VERSION)

.PHONY: stop
stop:: ##@Docker Stop the running container
	docker stop $(NAME)
    
.PHONY: clean
clean:: ##@Docker Remove the container
	docker rm -f $(NAME)

.PHONY: release
release:: ##@Docker Build and Ship
release:: build ship
```

#### Usage example

```
make build
make VERSION=testing build
make PORTS="-p 8080:80" run
make NAME=justtesting start
```

### docker-compose

```
.PHONY: up
up:: ##@Compose Start the whole thing
	docker-compose up
```

### rancher-compose

```
.PHONY: deploy
deploy:: ##@Rancher Deploy/Upgrade the stack, finishing earlier upgrades (build, ship, finish, deploy)
deploy:: build ship finish
    $(shell_env) rancher-compose -p $(RANCHER_STACK_NAME) up -d --upgrade

.PHONY: finish
finish:: ##@Rancher Finish an earlier upgrade
    $(shell_env) rancher-compose -p $(RANCHER_STACK_NAME) up -d --confirm-upgrade

.PHONY: rollback
rollback:: ##@Rancher Rollback an active upgrade
    $(shell_env) rancher-compose -p $(RANCHER_STACK_NAME) up -d --rollback
```

For information regarding the ``$(shell_env))`` see above.

#### rancher-compose with traefik labels

```docker-compose.yml
myapp:
  labels:
    io.rancher.container.pull_image: always
    io.rancher.container.hostname_override: container_name
    traefik.frontend.rule: ${TRAEFIK_FRONTEND_RULE}
    traefik.port: ${TRAEFIK_PORT}
  image: ${NS}/${REPO}:${VERSION}
```

```Makefile
$(eval $(call defw,TRAEFIK_FRONTEND_RULE,Host:www.myapp.com))
$(eval $(call defw,TRAEFIK_PORT,8080))

.PHONY: deploy
deploy:: ##@Rancher Deploy/Upgrade the stack, finishing earlier upgrades (build, ship, finish, deploy)
deploy:: build ship finish
    $(shell_env) rancher-compose -p $(RANCHER_STACK_NAME) up -d --upgrade
```

## Example output

Clone this repository and just call ``make help`` and/or ``make all``.

![](https://cloud.githubusercontent.com/assets/587018/18211721/6b01fc30-713f-11e6-95a2-9eb18ecbfc7e.png)

## Credits

  * [prwhite](https://github.com/prwhite) for the initial idea of self-documenting targets (https://gist.github.com/prwhite/8168133)
  * [lordnynex](https://github.com/lordnynex) for https://gist.github.com/prwhite/8168133#gistcomment-1712123
  * [HarasimowiczKamil](https://github.com/HarasimowiczKamil) for https://gist.github.com/prwhite/8168133#gistcomment-1727513
  * [boutin](https://github.com/bountin) and [dready](https://github.com/dready) for feedback and challeging the idea/concept

## Todo

  * allow categorization for variables too, maybe even bundle categorized variables with their correspondig, categorized targets for ``make help``
  * add example implementations for docker, docker-compose and rancher-compose