FROM ubuntu:24.04 as base

COPY bashrc /root/.bashrc
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g'     /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g'  /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g'  /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get install -y -q apt-utils dialog \
    && apt-get install -y -q sudo aptitude xz-utils flex bison libncurses5-dev make \
                             git exuberant-ctags bc libssl-dev libelf-dev gcc g++ \
                             python3 vim tmux lrzsz cpio build-essential rsync \
                             dwarves zstd kmod syslinux-utils isolinux


CMD ["bash"]
