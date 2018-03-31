export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

RUN_GPG := docker run -it --rm -v $(shell pwd):/gpg vladgh/gpg

terraform: src/configurations.tf terraform.tfstate terraform.tfstate.backup
	@docker run -it --rm \
		-v $(shell pwd)/src:/workspace \
		-v $(shell pwd)/.terraform:/.terraform \
		-v $(shell pwd)/terraform.tfstate:/terraform.tfstate \
		-v $(shell pwd)/terraform.tfstate.backup:/terraform.tfstate.backup \
		hashicorp/terraform $(ARGS) /workspace

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
