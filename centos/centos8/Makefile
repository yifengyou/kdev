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
	cd docker && docker build -t yifengyou/linux4.0:latest  .
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0:$(TIMESTAMP)
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0-centos:$(TIMESTAMP)
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0-centos8.5:$(TIMESTAMP)
	@echo "Build docker done!"

run:
	docker run -it --rm yifengyou/linux4.0:latest /bin/bash

pull:
	docker pull yifengyou/linux4.0:latest

push:
	docker push yifengyou/linux4.0:latest
	docker push yifengyou/linux4.0-centos:$(TIMESTAMP)
	docker push yifengyou/linux4.0-centos8.5:$(TIMESTAMP)
	docker push yifengyou/linux4.0:$(TIMESTAMP)
	@echo "Push docker done!"

vm:
	cd vm && ./build-vm.sh
	@echo "Build vm done!"

all: build push vm
	@echo "All done!All ok!"
