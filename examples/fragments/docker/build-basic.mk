# Define variables, export them and include them usage-documentation
$(eval $(call defw,NS,mydockernamespace))
$(eval $(call defw,REPO,mydockerrepo))
$(eval $(call defw,VERSION,latest))

# -----------------------------------------------------------------------------
# Build and ship
# -----------------------------------------------------------------------------
.PHONY: build
build:: ##@Docker Build an image
	@echo "$(TURQUOISE)Building image for application"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	docker build \
		-t $(NS)/$(REPO):$(VERSION) \
		--pull \
		.

.PHONY: ship
ship:: ##@Docker Ship the image
	docker push $(NS)/$(REPO):$(VERSION)

.PHONY: release
release:: ##@Docker Build and Ship
release:: build ship
