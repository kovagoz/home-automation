ENV ?= local

.PHONY: install
install:
	docker run --rm -it -v $(PWD):/host:ro -w /host \
		kovagoz/ansible-playbook -i inventories/$(ENV) playbook.yaml

.PHONY: up
up:
	vagrant up

.PHONY: down
down:
	vagrant destroy

.PHONY: shell
shell:
	vagrant ssh
