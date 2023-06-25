default:
	@echo "build            build docker image"
	@echo "pull             pull docker image"
	@echo "push             push docker image"

build:
	docker build . -t yifengyou/linux2.0:latest
	docker tag yifengyou/linux2.0:latest dockerproxy.com/yifengyou/linux2.0:latest 

pull:
	docker pull dockerproxy.com/yifengyou/linux2.0:latest
	docker tag dockerproxy.com/yifengyou/linux2.0:latest yifengyou/linux2.0:latest

push:
	docker push yifengyou/linux2.0:latest
