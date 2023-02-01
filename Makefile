SHELL := /bin/bash

-include .env

#
# Set VERBOSE=1 environment variable if you want to see
# the commands executed.
#
ifneq (1,$(VERBOSE))
.SILENT:
endif

.PHONY: help
help: col_width := 8
help: ## Show this help screen
	@echo
	@echo 'Usage: make <target>'
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(col_width)s\033[0m %s\n", $$1, $$2}'
	@echo

.PHONY: install
install: ## Prepare remote host
ifeq (,$(wildcard ./.env))
	cp env.example .env
	echo -e "\033[36mINFO:\033[0m .env has been created. Configure it then run 'make install' again!"
else
	docker run --rm -it \
		-v $(PWD):/host:ro \
		-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
		-e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
		-e ANSIBLE_REMOTE_USER=$(REMOTE_USER) \
		-e ANSIBLE_REMOTE_PORT=$(REMOTE_PORT) \
		-e ANSIBLE_BECOME=True \
		-e ANSIBLE_HOST_KEY_CHECKING=False \
		-w /host \
		kovagoz/ansible-playbook -i $(REMOTE_HOST), playbook.yaml
endif
