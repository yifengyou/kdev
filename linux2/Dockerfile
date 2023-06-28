FROM ubuntu:16.04 as base

COPY bashrc /root/.bashrc
RUN set -x && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y -q apt-utils dialog && \
    apt-get install -y -q sudo aptitude flex bison libncurses5-dev make git exuberant-ctags sparse bc libssl-dev libelf-dev && \
      apt-get install -y -q gcc-4.9 g++-4.9 gcc-4.9-plugin-dev gcc g++ \
        gcc-4.9-aarch64-linux-gnu g++-4.9-aarch64-linux-gnu gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        gcc-4.9-arm-linux-gnueabi g++-4.9-arm-linux-gnueabi gcc-arm-linux-gnueabi g++-arm-linux-gnueabi && \
      sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 100 && \
      sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-4.9 100 && \
      sudo update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ /usr/bin/arm-linux-gnueabi-g++-4.9 100 && \
      ln -svf /usr/bin/gcc-4.9 /usr/bin/gcc && \
      ln -svf /usr/bin/g++-4.9 /usr/bin/g++ && \
      sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 100 && \
      sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-4.9 100 && \
      sudo update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-4.9 100 && \
      sudo update-alternatives --install /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ /usr/bin/arm-linux-gnueabi-g++-4.9 100

CMD ["bash"]
