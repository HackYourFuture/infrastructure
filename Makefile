export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

WEB_VERSION = $(shell cd web && git rev-parse --short=7 HEAD)

RUN_TERRAFORM := docker run -it --rm \
		-v $(shell pwd)/src:/workspace \
		-v $(shell pwd)/web:/web \
		-v $(shell pwd)/.terraform:/.terraform \
		-v $(shell pwd)/terraform.tfstate:/terraform.tfstate \
		-v $(shell pwd)/terraform.tfstate.backup:/terraform.tfstate.backup hashicorp/terraform

RUN_GPG := docker run -it --rm -v $(shell pwd):/gpg vladgh/gpg

web/lambda.zip:
	@cd web && npm run lambda

terraform: src/configurations.tf terraform.tfstate terraform.tfstate.backup
	@$(RUN_TERRAFORM) $(ARGS) /workspace

init: src/configurations.tf
	@$(RUN_TERRAFORM) init /workspace

plan: src/configurations.tf
	@$(RUN_TERRAFORM) plan -var 'deploy_tag=$(WEB_VERSION)' /workspace

apply: src/configurations.tf
	@$(RUN_TERRAFORM) apply -var 'deploy_tag=$(WEB_VERSION)' /workspace

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
