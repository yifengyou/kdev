FROM debian:squeeze

COPY bashrc /root/.bashrc
COPY sources.list /etc/apt/sources.list
RUN echo "Acquire { https::Verify-Peer false }" > /etc/apt/apt.conf.d/99verify-peer.conf \
	&& echo "Acquire::Check-Valid-Until false;" >> /etc/apt/apt.conf \
	&& apt-get update --allow-unauthenticated \
	&& apt-get install --allow-unauthenticated -y systemd systemd-sysv \
	&& apt-get install --allow-unauthenticated -y \
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
		flex \
		bison \
		bc \
		libelf-dev \
		libssl-dev \
	&& rm -rf /etc/localtime \
	&& ln -vfs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

