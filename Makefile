export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

WEB_VERSION = $(shell cd web && git rev-parse --short=7 HEAD)

RUN_TERRAFORM := docker run -it --rm \
		-w="/workspace" \
		-v $(shell pwd)/src:/workspace \
		-v $(shell pwd)/web:/web \
		hashicorp/terraform

RUN_GPG := docker run -it --rm -v $(shell pwd):/gpg vladgh/gpg

clean:
	@rm -rf web

web:
	@git clone git@github.com:HackYourFuture/hackyourfuture.github.io.git web

update-web:
	@cd web && git pull origin master

web/api-$(WEB_VERSION).zip: web update-web
	@cd web && make upload-lambda

web/infra.config.json:
	@$(RUN_TERRAFORM) output -json > web/infra.config.json

terraform: src/configurations.tf terraform.tfstate terraform.tfstate.backup
	@$(RUN_TERRAFORM) $(ARGS)

.terraform: src/configurations.tf
	@$(RUN_TERRAFORM) init /workspace

plan: web/api-$(WEB_VERSION).zip .terraform
	@$(RUN_TERRAFORM) plan -var 'deploy_tag=$(WEB_VERSION)' /workspace

apply: web/api-$(WEB_VERSION).zip .terraform
	@$(RUN_TERRAFORM) apply -var 'deploy_tag=$(WEB_VERSION)' /workspace && \
	make web/infra.config.json

terraform.tfstate:
	@touch terraform.tfstate

terraform.tfstate.backup:
	@touch terraform.tfstate.backup

.PHONY: gpg
gpg:
	@$(RUN_GPG) $(ARGS)

src/configurations.tf:
	$(RUN_GPG) -o /gpg/src/configurations.tf -d /gpg/.secrets

encrypt: src/configurations.tf
	$(RUN_GPG) -o /gpg/.secrets -c /gpg/src/configurations.tf
