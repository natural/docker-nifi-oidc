DEFAULT_GOAL := help

IMAGES := oidc_testprovider
BUILD := $(addprefix build-,${IMAGES})
PULL := $(addprefix pull-,$(IMAGES))
CLEAN := $(addprefix clean-,$(IMAGES))

.PHONY: help
help:
	@fgrep -h "##" Makefile | fgrep -v fgrep | sed 's/\(.*\):.*##/\1:/'

.PHONY: build
build: ${BUILD} ## Build all images

.PHONY: pull
pull: ${PULL} ## Pull all -latest images

.PHONY: clean
clean: ${CLEAN} ## Clean images and other artifacts

.PHONY: ${BUILD}
${BUILD}: build-%:
	docker build -t $* -f dockerfiles/$* .

.PHONY: ${CLEAN}
${CLEAN}: clean-%:
	docker rmi $(subst _py,:py,$(*))
