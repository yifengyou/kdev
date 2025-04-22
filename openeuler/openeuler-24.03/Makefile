.PHONY: default help build run pull push vm all

TIMESTAMP=$(shell date +"%Y%m%d")

default: help

help:
	@echo "build            build docker image"
	@echo "pull             pull docker image"
	@echo "push             push docker image"
	@echo "run              just run up for test"
	@echo "vm               build qcow2 image"
	@echo "all              build docker and build vm"
	@echo TIMESTAMP: $(TIMESTAMP)

build:
	cd docker && docker build -t yifengyou/openeuler-linux6:latest  .
	docker tag yifengyou/openeuler-linux6:latest yifengyou/openeuler-linux6:$(TIMESTAMP)
	docker tag yifengyou/openeuler-linux6:latest yifengyou/openeuler-linux6-openeuler24.03-lts:$(TIMESTAMP)
	@echo "Build docker done!"

run:
	docker run -it --rm yifengyou/openeuler-linux6:latest /bin/bash

pull:
	docker pull yifengyou/openeuler-linux6:latest

push:
	docker push yifengyou/openeuler-linux6:latest
	docker push yifengyou/openeuler-linux6:$(TIMESTAMP)
	@echo "Push docker done!"

vm:
	cd vm && ./build-vm.sh
	@echo "Build vm done!"

all: build push vm
	@echo "All done!All ok!"

