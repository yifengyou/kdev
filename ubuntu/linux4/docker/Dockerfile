FROM debian:buster

COPY bashrc /root/.bashrc
COPY sources.list /etc/apt/sources.list
RUN echo "Acquire { https::Verify-Peer false }" > /etc/apt/apt.conf.d/99verify-peer.conf \
    && apt-get update \
	&& apt-get install -y systemd systemd-sysv ca-certificates \
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

