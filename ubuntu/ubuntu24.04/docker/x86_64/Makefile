.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker build -t yifengyou/linux6.0:latest  .
	docker tag yifengyou/linux6.0:latest yifengyou/linux6.0:$(TIMESTAMP)
	docker tag yifengyou/linux6.0:latest yifengyou/linux6.0-ubuntu:$(TIMESTAMP)
	docker tag yifengyou/linux6.0:latest yifengyou/linux6.0-ubuntu24.04:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux6.0:latest /bin/bash
	@echo "All done!"

