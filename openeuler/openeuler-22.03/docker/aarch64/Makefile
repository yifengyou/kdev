.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker build -t yifengyou/linux5.0-openeuler-2203:latest  .
	docker tag yifengyou/linux5.0-openeuler-2203:latest yifengyou/linux5.0-openeuler-2203:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux5.0-openeuler-2203:latest /bin/bash
	@echo "All done!"

