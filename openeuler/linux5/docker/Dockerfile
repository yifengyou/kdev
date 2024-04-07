FROM openeuler/openeuler:22.03-lts-sp1 as base

COPY bashrc /root/.bashrc
RUN yum makecache \
    && yum install -y gcc make sudo flex bison tmux cscope sysstat vim \
           rpm-build patchutils xmlto asciidoc elfutils-libelf-devel \
           elfutils-devel zlib-devel binutils-devel newt-devel python3-devel \
           perl audit-libs-devel hmaccalc perl-ExtUtils-Embed dnf-plugins-core

CMD ["bash"]
