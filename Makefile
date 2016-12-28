include *.mk

# Define variables, export them and include them usage-documentation
$(eval $(call defw,I_AM_A_VARIABLE,I_AM_THE_VALUE))

.PHONY: all
all: ##@Examples Run all examples
all: example-se example-interface

.PHONY: example-se
example-se: ##@Examples How to use $(shell_env)
	@echo ""
	@echo 'example: how to to use $$(shell_env)'
	@printf "=%.0s" {1..80}
	@echo ""
	@echo '$$(shell_env) my_command'
	$(shell_env) echo "echoing I_AM_A_VARIABLE=$${I_AM_A_VARIABLE}"

.PHONY: example-interfaces
example-interface:: ##@Examples Abuse double-colon rules
	@echo ""
	@echo "example: using double-colon rules to create and implement interface-ish targets"
	@printf "=%.0s" {1..80}
	@echo ""
	@echo "define 'target:: ##@Category not implemement' in .mk"
	@echo "implement 'target:: ##@Category this is nice' in Makefile"

.PHONY: category-name-test
category-name-test: ##@Category with space	description separated by tab
	@echo ""
