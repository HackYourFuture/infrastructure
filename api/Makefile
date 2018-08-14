RUN_AWS_CLI := docker run -it --rm \
		-v $(shell pwd):/workspace \
		-v ~/.aws:/root/.aws \
		-e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
		-e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
		-e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"\
		mesosphere/aws-cli

VERSION = $(shell git rev-parse --short=7 HEAD)

node_modules:
	@npm install

prepare: node_modules

dist: prepare
	@npm run build

infra-api-$(VERSION).zip: dist
	@cd dist && zip -r ./../infra-api-$(VERSION).zip *

upload-lambda: infra-api-$(VERSION).zip
	@$(RUN_AWS_CLI) s3 cp /workspace/infra-api-$(VERSION).zip s3://hyf-api-deploy/infra-api-$(VERSION).zip

publish-api: clean upload-lambda
	@$(RUN_AWS_CLI) lambda update-function-code --s3-bucket=hyf-api-deploy --s3-key=infra-api-$(VERSION).zip --publish --function-name=infra_proxy &> /dev/null && \
	echo "Function updated"

publish: publish-api

.PHONY: clean
clean:
	@rm -rf dist
