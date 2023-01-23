SHELL := /bin/bash

ifneq (1,$(VERBOSE))
.SILENT:
endif

define notice
	@echo -e '\033[1m$(bullet) $(1)\033[0m'
endef

bullet := ✓

.PHONY: help
help: col_width := 11
help:
	@echo
	@echo 'Usage: make <target>'
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(col_width)s\033[0m %s\n", $$1, $$2}'
	@echo

.PHONY: install
install: .env ## Configure the IoT stack
install: services/zigbee2mqtt/data
install: services/homebridge/data
install: services/zigbee2mqtt/network_key.yaml

.env:
	$(call notice,Set time zone)
	echo TIMEZONE=Europe/Budapest >> $@
	$(call notice,Set the USB Zigbee device)
	echo ZIGBEE_DEVICE=$(shell ls -1 /dev/serial/by-id/* | head -n1) >> $@
	$(call notice,Generate random PAN ID)
	echo ZIGBEE2MQTT_CONFIG_ADVANCED_PAN_ID=$(firstword $(shell od -An -td -N2 /dev/urandom)) >> $@

services/%/data:
	$(call notice,Create directory: $@)
	mkdir -p $@

.PHONY: up
up: ## Spin up the docker containers
ifeq (,$(wildcard ./.env))
	$(error You must run "make install" first)
endif
	docker compose up -d
#
# If package.json does not exist, it means, that homebridge container
# has never been started, so we have to install the z2m plugin after
# the first start.
#
ifeq (,$(wildcard ./services/homebridge/data/package.json))
	docker compose exec homebridge hb-service add homebridge-z2m
#
# Add z2m configuration to the main homebridge config.
#
	cat services/homebridge/data/config.json \
		| jq -r --argjson z2m "$$(<services/homebridge/z2m.json)" '.platforms += [$$z2m]' \
		> /tmp/config.json
	sudo mv /tmp/config.json services/homebridge/data
endif

.PHONY: down
down: ## Destroy all containers
	docker compose down

services/zigbee2mqtt/network_key.yaml:
	$(call notice,Generate Zigbee network key)
	echo network_key: > $@
	for i in {1..16}; do echo "  - $$(( $$RANDOM % 255 ))" >> $@; done

.PHONY: uninstall
uninstall: ## Delete all configuration
	sudo rm -rf \
		services/zigbee2mqtt/data \
		services/zigbee2mqtt/network_key.yaml \
		services/homebridge/data \
		.env

.PHONY: sync
sync:
	rsync -a --exclude .git . pi@192.168.68.69:/home/pi/testbench
