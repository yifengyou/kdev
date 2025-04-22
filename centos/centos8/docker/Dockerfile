FROM centos:8 as base

COPY bashrc /root/.bashrc
COPY centos.repo /etc/yum.repos.d/
RUN rm -f /etc/yum.repos.d/CentOS* \
    && yum makecache \
    && yum install -y gcc make sudo flex bison tmux cscope sysstat vim \
           rpm-build yum-utils patchutils xmlto asciidoc elfutils-libelf-devel \
           elfutils-devel zlib-devel binutils-devel newt-devel python3-devel \
           perl audit-libs-devel hmaccalc perl-ExtUtils-Embed

CMD ["bash"]
