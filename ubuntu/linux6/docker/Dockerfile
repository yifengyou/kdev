FROM ubuntu:24.04 as base

COPY bashrc /root/.bashrc
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y -q apt-utils dialog \
    && apt-get install -y -q sudo xz-utils flex bison libncurses5-dev make git exuberant-ctags bc libssl-dev libelf-dev \
       gcc g++ tmux lrzsz cpio build-essential dwarves rsync


CMD ["bash"]
