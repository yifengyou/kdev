FROM debian:bullseye

COPY bashrc /root/.bashrc
COPY sources.list /etc/apt/sources.list
RUN apt-get update \
	&& apt-get install -y systemd systemd-sysv \
	&& apt-get install -y \
		vim \
		gcc \
		kmod \
		dwarves \
		cpio \
		build-essential \
		make \
		libncurses-dev \
		libmpc-dev \
		apt-file \
		xfsprogs \
		file \
		rsync \
		bear \
		git \
		gcc-aarch64-linux-gnu \
		flex \
		bison \
		bc \
		libelf-dev \
		libssl-dev \
	&& rm -rf /etc/localtime \
	&& ln -vfs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

