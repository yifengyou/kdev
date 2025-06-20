.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker build -t yifengyou/linux6.0-openeuler-2403:latest  .
	docker tag yifengyou/linux6.0-openeuler-2403:latest yifengyou/linux6.0-openeuler-2403:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux6.0-openeuler-2403:latest /bin/bash
	@echo "All done!"

