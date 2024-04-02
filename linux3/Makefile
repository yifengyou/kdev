TIMESTAMP=$(shell date +"%Y%m%d")

default:
	@echo "build            build docker image"
	@echo "pull             pull docker image"
	@echo "push             push docker image"
	@echo "run              just run up for test"
	@echo TIMESTAMP: $(TIMESTAMP)

build:
	docker build -t yifengyou/linux3.0:latest  .
	docker tag yifengyou/linux3.0:latest yifengyou/linux3.0:$(TIMESTAMP)

run:
	docker run -it --rm yifengyou/linux3.0:latest /bin/bash

pull:
	docker pull yifengyou/linux3.0:latest

push:
	docker push yifengyou/linux3.0:latest
	docker push yifengyou/linux3.0:$(TIMESTAMP)
