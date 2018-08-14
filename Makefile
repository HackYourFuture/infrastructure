SHELL:=/bin/bash
export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

ifeq ($(shell test -e .env && echo -n yes),yes)
		include .env
		export $(shell sed 's/=.*//' .env)
endif

INFRA_VERSION = $(shell git rev-parse --short=7 HEAD)
WEB_VERSION = $(shell cd web && git rev-parse --short=7 HEAD)

RUN_TERRAFORM := docker run -it --rm \
		-w="/workspace" \
		--env-file .env \
		--env TF_VAR_AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env TF_VAR_AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		--env TF_VAR_AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--env TF_VAR_GITHUB_APP_TOKEN=$(GITHUB_APP_TOKEN) \
		--env TF_VAR_GITHUB_APP_SECRET=$(GITHUB_APP_SECRET) \
		--env TF_VAR_GITHUB_APP_URL=$(GITHUB_APP_URL) \
		--env TF_VAR_website_api_deploy_tag=$(WEB_VERSION) \
		--env TF_VAR_infra_api_deploy_tag=$(INFRA_VERSION) \
		-v $(shell pwd)/src:/workspace \
		-v $(shell pwd)/web:/web \
		hashicorp/terraform

RUN_AWS_CLI := docker run -it --rm \
		-v $(shell pwd):/workspace \
		-v ~/.aws:/root/.aws \
		-e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
		-e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
		-e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"\
		mesosphere/aws-cli

RUN_GPG := docker run -it --rm -v $(shell pwd):/gpg vladgh/gpg

debug:
	@printenv

.PHONY: clean
clean:
	@rm -rf web

web:
	@git clone git@github.com:HackYourFuture/hackyourfuture.github.io.git web

.PHONY: update-web
update-web:
	@cd web && git checkout -- . && git pull origin master

web/api-$(WEB_VERSION).zip: web update-web
	@cd web && make upload-lambda

api/infra-$(INFRA_VERSION).zip:
	@cd api && make upload-lambda

web/infra.config.json:
	@$(RUN_TERRAFORM) output -json > web/infra.config.json

.PHONY: terraform
terraform: .env
	@$(RUN_TERRAFORM) $(ARGS)

.terraform: .env
	@$(RUN_TERRAFORM) init

plan: .terraform
	@$(RUN_TERRAFORM) plan -var 'deploy_tag=$(WEB_VERSION)' /workspace

apply: web/api-$(WEB_VERSION).zip api/infra-$(INFRA_VERSION).zip .terraform
	@$(RUN_TERRAFORM) apply -var 'deploy_tag=$(WEB_VERSION)' /workspace && \
	make web/infra.config.json

.PHONY: gpg
gpg:
	@$(RUN_GPG) $(ARGS)

.env.enc:
	@$(RUN_AWS_CLI) s3 cp s3://hyf-api-deploy/secrets/.env.enc /workspace/.env.enc

.env: .env.enc
	@$(RUN_GPG) -o /gpg/.env -d /gpg/.env.enc

.PHONY: encrypt-env
encrypt-env:
	@$(RUN_GPG) -o /gpg/.env.enc -c /gpg/.env && \
	$(RUN_AWS_CLI) s3 cp /workspace/.env.enc s3://hyf-api-deploy/secrets/.env.enc
