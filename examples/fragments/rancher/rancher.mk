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
