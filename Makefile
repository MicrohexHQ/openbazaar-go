.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

##
## Building
##
deploy:	## Finalize for release and push to Github
	./deploy.sh

build:	## Build all versions
	./build.sh

linux_binary:	## Build for 64bit linux
	./build.sh linux/amd64

##
## Protobuf compilation
##
P_TIMESTAMP = Mgoogle/protobuf/timestamp.proto=github.com/golang/protobuf/ptypes/timestamp
P_ANY = Mgoogle/protobuf/any.proto=github.com/golang/protobuf/ptypes/any

PKGMAP = $(P_TIMESTAMP),$(P_ANY)

protos:	## Build protobuffers
	cd pb/protos && protoc --go_out=$(PKGMAP):.. *.proto

##
## Docker
##
DOCKER_PROFILE ?= openbazaar
DOCKER_TAG ?= $(shell git describe --tags --abbrev=0)
DOCKER_IMAGE_NAME ?= $(DOCKER_PROFILE)/server:$(DOCKER_TAG)

docker:	## Build Docker image
	docker build -t $(DOCKER_IMAGE_NAME) .

docker_push:	## Push latest docker image to Docker repo
	docker push $(DOCKER_IMAGE_NAME)

##
## Cleanup
##
clean_build:	## Remove compiled binaries
	rm -f ./dist/*

clean_docker:	## Remove latest docker image
	docker rmi -f $(DOCKER_SERVER_IMAGE_NAME) || true

clean: clean_build clean_docker	## Remove all build aritfacts
