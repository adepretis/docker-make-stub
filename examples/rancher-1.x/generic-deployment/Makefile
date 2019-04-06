include .stub/*.mk

# Docker
$(eval $(call defw,NS,docker-hub-organisation))
$(eval $(call defw,REPO,awesome-app))
$(eval $(call defw,VERSION,latest))
$(eval $(call defw,NAME,$(REPO)))

# Rancher
$(eval $(call defw,RANCHER_ACCESS_KEY,))
$(eval $(call defw,RANCHER_SECRET_KEY,))
$(eval $(call defw,RANCHER_URL,https://my-awesome.rancher.server))
$(eval $(call defw,RANCHER_STACK_NAME,$(NAME)))

# Traefik
$(eval $(call defw,TRAEFIK_FRONTEND_RULE,))


# -----------------------------------------------------------------------------
# Alll things deployment
# -----------------------------------------------------------------------------
.PHONY: deploy
deploy:: ##@Rancher Deploy the stack and finish former upgrades
deploy:: finish
	$(shell_env) rancher-compose \
		-p $(RANCHER_STACK_NAME) \
		-r rancher-compose.yml \
		up \
		-d \
		--force-upgrade \
		--pull

.PHONY: finish
finish:: ##@Rancher Finish an earlier upgrade
	$(shell_env) rancher-compose \
		-p $(RANCHER_STACK_NAME) \
		-r rancher-compose.yml \
		up \
		-d \
		--confirm-upgrade

.PHONY: rollback
rollback:: ##@Rancher Rollback an active upgrade
	$(shell_env) rancher-compose \
		-p $(RANCHER_STACK_NAME) \
		-r rancher-compose.yml \
		up \
		-d \
		--rollback
