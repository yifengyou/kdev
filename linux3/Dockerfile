FROM ubuntu:14.04 as base

COPY bashrc /root/.bashrc
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y -q apt-utils dialog \
    && apt-get install -y -q sudo aptitude xz-utils flex bison libncurses5-dev make git exuberant-ctags bc libssl-dev libelf-dev \
       gcc g++ vim tmux lrzsz


CMD ["bash"]
