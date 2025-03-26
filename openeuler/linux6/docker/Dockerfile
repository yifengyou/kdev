FROM hub.rat.dev/openeuler/openeuler:24.03-lts

COPY bashrc /root/.bashrc
RUN yum makecache \
    && yum install -y gcc make sudo flex bison tmux cscope sysstat vim \
           rpm-build patchutils xmlto asciidoc elfutils-libelf-devel \
           elfutils-devel zlib-devel binutils-devel newt-devel python3-devel \
           perl audit-libs-devel hmaccalc perl-ExtUtils-Embed dnf-plugins-core \
           openssl-devel m4 hostname dwarves rsync

CMD ["bash"]
