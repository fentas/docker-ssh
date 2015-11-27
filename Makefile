NS = $(DOCKER_NS_GCE)
VERSION ?= latest

REPO = ssh
NAME = ssh

.PHONY: build push shell release

build:
	docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	gcloud docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t --env-file $(NS)/$(REPO)^:$(VERSION) /bin/bash

release: build
	make push -e VERSION=$(VERSION)

default: build
