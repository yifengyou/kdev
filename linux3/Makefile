default:
	@echo "build            build docker image"
	@echo "pull             pull docker image"
	@echo "push             push docker image"

build:
	docker build --build-arg GCC_VERSION=5 --build-arg UBUNTU_VERSION=16.04 --build-arg UNAME=root --build-arg UID=0 --build-arg GID=0 -t yifengyou/linux3.0:latest  .
	docker tag yifengyou/linux3.0:latest dockerproxy.com/yifengyou/linux3.0:latest 

pull:
	docker pull dockerproxy.com/yifengyou/linux3.0:latest
	docker tag dockerproxy.com/yifengyou/linux3.0:latest yifengyou/linux3.0:latest

push:
	docker push yifengyou/linux3.0:latest
