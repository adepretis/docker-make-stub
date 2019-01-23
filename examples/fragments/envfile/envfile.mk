ifneq ($(wildcard .env),)
  $(info $(YELLOW)including .env file$(RESET))
  include .env
endif
