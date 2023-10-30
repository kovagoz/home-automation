ENV ?= local

.PHONY: install
install:
	docker run --rm -it \
		-v $(PWD):/host:ro \
		-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
		-e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
		-w /host \
		kovagoz/ansible-playbook -i inventories/local playbook.yaml

.PHONY: up
up:
	vagrant up

.PHONY: down
down:
	vagrant destroy

.PHONY: shell
shell:
	vagrant ssh
