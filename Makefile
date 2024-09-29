ENV  ?= local
TAGS ?= all

# Only the live environment is configurable.
# You don't need to configure the local environment.
ifeq ($(ENV),live)
-include .env
endif

.env:
	cp .env.example $@

ansible := ansible -i inventories/$(ENV)
ansible_playbook := ansible-playbook -i inventories/$(ENV)

.PHONY: install
install:
	$(ansible_playbook) --tags $(TAGS) \
		--extra-vars zigbee_pan_id=$(ZIGBEE_PAN_ID) \
		--extra-vars zigbee_network_key=$(ZIGBEE_NETWORK_KEY) \
		--extra-vars ssh_host=$(REMOTE_HOST) \
		--extra-vars ssh_username=$(REMOTE_USERNAME) \
		--extra-vars ssh_password=$(REMOTE_PASSWORD) \
		--extra-vars 'ssh_pubkey=$(REMOTE_PUBKEY)' \
		--extra-vars dashboard_username=$(DASHBOARD_USERNAME) \
		--extra-vars dashboard_password=$(DASHBOARD_PASSWORD) \
		playbook.yaml

.PHONY: up
up:
	vagrant up

.PHONY: down
down:
	vagrant destroy --force

.PHONY: shell
shell:
ifeq ($(ENV),local)
	vagrant ssh
else ifeq ($(ENV),live)
	ssh $(REMOTE_USERNAME)@$(REMOTE_HOST) -o PreferredAuthentications=password,publickey
else
$(error Unknown environment)
endif