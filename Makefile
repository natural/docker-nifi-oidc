DEFAULT_GOAL := help

IMAGES := nifi-oidc-test-provider
BUILD := $(addprefix build-,${IMAGES})
CLEAN := $(addprefix clean-,$(IMAGES))

.PHONY: help
help:
	@fgrep -h "##" Makefile | fgrep -v fgrep | sed 's/\(.*\):.*##/\1:/'

.PHONY: build
build: ${BUILD} ## Build all images

.PHONY: clean
clean: ${CLEAN} ## Clean images and other artifacts

.PHONY: ${BUILD}
${BUILD}: build-%:
	docker build -t $* -f services/$* .

.PHONY: ${CLEAN}
${CLEAN}: clean-%:
	docker rmi $(subst _py,:py,$(*))
