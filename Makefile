ENV  ?= local
TAGS ?= all

ansible_docker := docker run --rm -it \
	-v $(PWD):/host:ro \
	-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
	-e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
	-w /host

ansible := $(ansible_docker) \
	--entrypoint ansible \
	kovagoz/ansible-playbook -i inventories/$(ENV)

ansible_playbook := $(ansible_docker) \
	kovagoz/ansible-playbook -i inventories/$(ENV)

.PHONY: install
install:
	$(ansible_playbook) --tags $(TAGS) \
		playbook.yaml

.PHONY: up
up:
	vagrant up

.PHONY: down
down:
	vagrant destroy --force

.PHONY: shell
shell:
	vagrant ssh
