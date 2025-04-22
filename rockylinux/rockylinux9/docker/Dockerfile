FROM rockylinux:9 as base

COPY bashrc /root/.bashrc
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak /etc/yum.repos.d/*.repo \
    && yum makecache \
    && yum install -y gcc make sudo flex bison tmux cscope sysstat vim \
           rpm-build yum-utils patchutils xmlto asciidoc elfutils-libelf-devel \
           elfutils-devel zlib-devel binutils-devel newt-devel python3-devel \
           perl audit-libs-devel hmaccalc perl-ExtUtils-Embed

CMD ["bash"]
