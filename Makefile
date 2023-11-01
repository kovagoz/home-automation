ENV  ?= local
TAGS ?= all

.PHONY: install
install:
	docker run --rm -it -v $(PWD):/host:ro -w /host \
		kovagoz/ansible-playbook -i inventories/$(ENV) --tags $(TAGS) playbook.yaml

.PHONY: up
up:
	vagrant up

.PHONY: down
down:
	vagrant destroy --force

.PHONY: shell
shell:
	vagrant ssh
