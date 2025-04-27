.PHONY: default run

TIMESTAMP=$(shell date +"%Y%m%d")

build:
	docker build -t yifengyou/linux4.0-openeuler-2003:latest  .
	docker tag yifengyou/linux4.0-openeuler-2003:latest yifengyou/linux4.0-openeuler-2003:$(TIMESTAMP)
	@echo "All done!"

run:
	docker run -it --rm yifengyou/linux4.0-openeuler-2003:latest /bin/bash
	@echo "All done!"

