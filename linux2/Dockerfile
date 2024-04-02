FROM ubuntu:12.04 as base

COPY bashrc /root/.bashrc
RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y -q apt-utils dialog \
    && apt-get install -y -q build-essential gcc g++ make sudo aptitude xz-utils \
    flex bison libncurses5-dev vim automake git exuberant-ctags bc libelf-dev \
    libncurses5-dev libssl-dev libpci-dev libdevmapper-dev zlib1g-dev tmux lrzsz \
    sysstat cscope

CMD ["bash"]
