.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker build -t yifengyou/linux4.0:latest  .
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0:$(TIMESTAMP)
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0-ubuntu:$(TIMESTAMP)
	docker tag yifengyou/linux4.0:latest yifengyou/linux4.0-ubuntu18.04:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux4.0:latest /bin/bash
	@echo "All done!"

