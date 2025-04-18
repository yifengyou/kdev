.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker pull hub.rat.dev/ubuntu:22.04
	docker tag hub.rat.dev/ubuntu:22.04 ubuntu:22.04
	docker build -t yifengyou/linux5.0:latest  .
	docker tag yifengyou/linux5.0:latest yifengyou/linux5.0:$(TIMESTAMP)
	docker tag yifengyou/linux5.0:latest yifengyou/linux5.0-ubuntu:$(TIMESTAMP)
	docker tag yifengyou/linux5.0:latest yifengyou/linux5.0-ubuntu22.04:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux5.0:latest /bin/bash
	@echo "All done!"


