# kdev (linux kernel development tools)

```
Something I hope you know before go into the coding~
First, please watch or star this repo, I'll be more happy if you follow me.
Bug report, questions and discussion are welcome, you can post an issue or pull a request.
```

## 项目描述

本仓库提供kdev工具，用于快速构建内核编译环境、测试环境（QEMU/KVM）。

1. 使用Docker容器编译内核，规避编译环境差异（工具链，dwarves，python3，etc...）
2. 使用Qemu-kvm虚机运行内核
3. 适配linux 2/3/4/5/6内核版本，发行版默认使用Ubuntu

| Ubuntu 版本            | 代号                | 内核版本  | 源码仓库                                                |
| ---------------------- | ------------------- | --------- | ------------------------------------------------------- |
| Ubuntu 24.04.X **LTS** | **Noble** Numbat    | 6.8.4     | [linux-6.git](https://github.com/yifengyou/linux-6.git) |
| Ubuntu 22.04.X **LTS** | **Jammy** Jellyfish | 5.15.60   | [linux-5.git](https://github.com/yifengyou/linux-5.git) |
| Ubuntu 18.04.X **LTS** | **Bionic** Beaver   | 4.15.18   | [linux-4.git](https://github.com/yifengyou/linux-4.git) |
| Ubuntu 14.04.5 **LTS** | **Trusty** Tahr     | 3.13.11   | [linux-3.git](https://github.com/yifengyou/linux-3.git) |
| Ubuntu 10.04.X **LTS** | **Lucid** Lynx      | 2.6.32.63 | [linux-2.git](https://github.com/yifengyou/linux-2.git) |

## 目录

## 极速入门

以 Linux 6 （Ubuntu 24.04）为例，请先准备好内核源代码


```
git clone https://github.com/yifengyou/linux-6.git -b master linux-6.git
```



### 构建镜像

* 构建 Docker 镜像，用于内核编译

```
cd ubuntu/linux6 && make build
```

* 构建 qcow2 镜像，用于运行内核

```
cd ubuntu/linux6 && make vm
```

### 添加配置文件

/linux/linux-6.git-build-x86_64/ 作为编译输出目录，配置文件放置于 `/linux/linux-6.git-build-x86_64/linux6.kdev` ， 其内容为：

```
sourcedir = /linux/linux-6.git
nbd = nbd6
arch = x86_64
debug = True
skipimagecheck = True
vmname = kdev-linux6
config = ubuntu24_x86_64_defconfig
nodocker = False
mrproper = False
rclocal = /linux/linux-6.git-build-x86_64/rclocal
qcow2_image = /linux/linux-6.git-build-x86_64/rootfs.qcow2
```

其中，关键参数：

* sourcedir : kernel源代码所在目录(完整路径)
* config : 内核编译所使用的config配置，x86_64位于 `arch/x86/configs/` 目录下
* qcow2_image : 用kdev构建的qcow2镜像完整路径
* rclocal : 虚机第一次运行时执行的脚本
* vmname : 虚机名称
* mrproper : 是否彻底清空再编译内核


### 编译内核

```
kdev kernel
```

将内核源代码`/linux/linux-6.git` 编译输出到 `/linux/linux-6.git-build-x86_64/`目录下

编译输出内容包括：

*. boot/{vmlinux, config, System.map} : 内核二进制，配置，地址表
*. lib/modules : 内核模块
*. usr/src/linux-headers : 内核头文件

### 构建rootfs

```
kdev rootfs
```

将编译内容拷贝到目标qcow2镜像


### 运行

```
kdev run
```

使用 qemu-kvm 将qcow2镜像运行起来


## TODO

1. 增加KGDB支持
2. 增加CentOS系列发行版支持
3. ...



## 详细说明


## kdev kernel

```
[root@X99F8D /linux/linux-6.git-build-x86_64]# kdev kernel
2024-05-05 11:09:34,526 [DEBUG] kdev: Enable debug output
2024-05-05 11:09:34,526 [DEBUG] kdev: Parser and config:
2024-05-05 11:09:34,526 [DEBUG] kdev:   version = False
2024-05-05 11:09:34,526 [DEBUG] kdev:   help = False
2024-05-05 11:09:34,527 [DEBUG] kdev:   verbose = None
2024-05-05 11:09:34,527 [DEBUG] kdev:   sourcedir = /kernel/linux-6.git
2024-05-05 11:09:34,527 [DEBUG] kdev:   arch = x86_64
2024-05-05 11:09:34,527 [DEBUG] kdev:   workdir = None
2024-05-05 11:09:34,527 [DEBUG] kdev:   debug = True
2024-05-05 11:09:34,527 [DEBUG] kdev:   nodocker = False
2024-05-05 11:09:34,527 [DEBUG] kdev:   job = 56
2024-05-05 11:09:34,527 [DEBUG] kdev:   clean = None
2024-05-05 11:09:34,527 [DEBUG] kdev:   config = ubuntu24_x86_64_defconfig
2024-05-05 11:09:34,528 [DEBUG] kdev:   bash = None
2024-05-05 11:09:34,528 [DEBUG] kdev:   mrproper = False
2024-05-05 11:09:34,528 [DEBUG] kdev:   func = <function timer.<locals>.wrapper at 0x7f713a97b940>
2024-05-05 11:09:34,528 [DEBUG] kdev:   nbd = nbd6
2024-05-05 11:09:34,528 [DEBUG] kdev:   skipimagecheck = True
2024-05-05 11:09:34,528 [DEBUG] kdev:   vmname = kdev-linux6
2024-05-05 11:09:34,528 [DEBUG] kdev:   rclocal = /kernel/linux-6.git-build-x86_64/rclocal
2024-05-05 11:09:34,529 [DEBUG] kdev:   qcow2_image = /linux/linux-6.git-build-x86_64/rootfs.qcow2
2024-05-05 11:09:34,529 [INFO] kdev: -> Step check environment
2024-05-05 11:09:34,529 [INFO] kdev: Target arch = [ x86_64 ]
2024-05-05 11:09:34,529 [INFO] kdev: workdir : /kernel/linux-6.git-build-x86_64
2024-05-05 11:09:34,529 [INFO] kdev: Check /kernel/linux-6.git ok! It's kernel source directory.
2024-05-05 11:09:34,529 [INFO] kdev: -> Exe cmd:make kernelversion
2024-05-05 11:09:34,559 [INFO] kdev: kernel version : 6.8.4
2024-05-05 11:09:34,559 [INFO] kdev: master version : 6
2024-05-05 11:09:34,559 [INFO] kdev: -> Step build kernel
2024-05-05 11:09:34,560 [INFO] kdev:  set kenrel config from cmdline ubuntu24_x86_64_defconfig
2024-05-05 11:09:34,560 [INFO] kdev: build kernel in docker
2024-05-05 11:09:34,560 [INFO] kdev:  using docker image : yifengyou/linux6.0:latest
2024-05-05 11:09:34,560 [INFO] kdev: -> Exe cmd:docker run -t -v /kernel/linux-6.git-build-x86_64/dockerbuild.sh:/bin/kdev -v /kernel/linux-6.git:/kernel -v /kernel/linux-6.git-build-x86_64:/workdir -w /workdir yifengyou/linux6.0:latest /bin/kdev
2024-05-05 11:09:35,272 [INFO] kdev: STDOUT + '[' '!' -f /.dockerenv ']'
+ WORKDIR=/workdir
+ SOURCEDIR=/kernel
+ ARCH=x86_64
+ CROSS_COMPILE=
+ KERNEL_HEADER_INSTALL=6.8.4
+ JOB=56
+ cd /kernel
+ mkdir -p /workdir/build
2024-05-05 11:09:35,275 [INFO] kdev: STDOUT + make O=/workdir/build ARCH=x86_64 CROSS_COMPILE= ubuntu24_x86_64_defconfig
2024-05-05 11:09:35,283 [INFO] kdev: STDOUT make[1]: Entering directory '/workdir/build'
2024-05-05 11:09:35,506 [INFO] kdev: STDOUT GEN     Makefile
2024-05-05 11:09:37,834 [INFO] kdev: STDOUT #
# No change to .config
#
2024-05-05 11:09:37,839 [INFO] kdev: STDOUT make[1]: Leaving directory '/workdir/build'
2024-05-05 11:09:37,839 [INFO] kdev: STDOUT + '[' 0 -ne 0 ']'
+ ls -alh /workdir/build/.config
2024-05-05 11:09:37,842 [INFO] kdev: STDOUT -rw-r--r-- 1 root root 281K May  5 01:19 /workdir/build/.config
2024-05-05 11:09:37,842 [INFO] kdev: STDOUT + make O=/workdir/build ARCH=x86_64 CROSS_COMPILE= -j 56
2024-05-05 11:09:37,849 [INFO] kdev: STDOUT make[1]: Entering directory '/workdir/build'
2024-05-05 11:09:38,875 [INFO] kdev: STDOUT GEN     Makefile
2024-05-05 11:09:38,906 [INFO] kdev: STDOUT UPD     include/generated/compile.h
2024-05-05 11:09:38,911 [INFO] kdev: STDOUT mkdir -p /workdir/build/tools/objtool && make O=/workdir/build subdir=tools/objtool --no-print-directory -C objtool
2024-05-05 11:09:38,917 [INFO] kdev: STDOUT mkdir -p /workdir/build/tools/bpf/resolve_btfids && make O=/workdir/build subdir=tools/bpf/resolve_btfids --no-print-directory -C bpf/resolve_btfids
2024-05-05 11:09:39,047 [INFO] kdev: STDOUT INSTALL libsubcmd_headers
2024-05-05 11:09:39,087 [INFO] kdev: STDOUT INSTALL libsubcmd_headers
2024-05-05 11:09:39,218 [INFO] kdev: STDOUT CALL    /kernel/scripts/checksyscalls.sh
2024-05-05 11:09:39,460 [INFO] kdev: STDOUT CC      init/version.o
2024-05-05 11:09:40,746 [INFO] kdev: STDOUT AR      init/built-in.a
2024-05-05 11:09:43,426 [INFO] kdev: STDOUT CHK     kernel/kheaders_data.tar.xz
2024-05-05 11:09:43,897 [INFO] kdev: STDOUT GEN     kernel/kheaders_data.tar.xz
2024-05-05 11:10:08,343 [INFO] kdev: STDOUT CC [M]  kernel/kheaders.o
2024-05-05 11:10:08,989 [INFO] kdev: STDOUT AR      built-in.a
2024-05-05 11:10:09,242 [INFO] kdev: STDOUT AR      vmlinux.a
2024-05-05 11:10:09,659 [INFO] kdev: STDOUT LD      vmlinux.o
2024-05-05 11:10:14,367 [INFO] kdev: STDOUT OBJCOPY modules.builtin.modinfo
2024-05-05 11:10:14,475 [INFO] kdev: STDOUT GEN     modules.builtin
2024-05-05 11:10:14,554 [INFO] kdev: STDOUT GEN     .vmlinux.objs
2024-05-05 11:10:14,607 [INFO] kdev: STDOUT MODPOST Module.symvers
```


## kdev rootfs

```
# kdev rootfs
2024-05-05 11:02:20,854 [DEBUG] kdev: Enable debug output
2024-05-05 11:02:20,854 [DEBUG] kdev: Parser and config:
2024-05-05 11:02:20,854 [DEBUG] kdev:   version = False
2024-05-05 11:02:20,854 [DEBUG] kdev:   help = False
2024-05-05 11:02:20,854 [DEBUG] kdev:   verbose = None
2024-05-05 11:02:20,854 [DEBUG] kdev:   sourcedir = /kernel/linux-6.git
2024-05-05 11:02:20,854 [DEBUG] kdev:   arch = x86_64
2024-05-05 11:02:20,854 [DEBUG] kdev:   workdir = None
2024-05-05 11:02:20,854 [DEBUG] kdev:   debug = True
2024-05-05 11:02:20,855 [DEBUG] kdev:   release = None
2024-05-05 11:02:20,855 [DEBUG] kdev:   qcow2_image = /linux/linux-6.git-build-x86_64/rootfs.qcow2
2024-05-05 11:02:20,855 [DEBUG] kdev:   func = <function timer.<locals>.wrapper at 0x7fb4060c6af0>
2024-05-05 11:02:20,855 [DEBUG] kdev:   nbd = nbd6
2024-05-05 11:02:20,855 [DEBUG] kdev:   skipimagecheck = True
2024-05-05 11:02:20,855 [DEBUG] kdev:   vmname = kdev-linux6
2024-05-05 11:02:20,855 [DEBUG] kdev:   config = ubuntu24_x86_64_defconfig
2024-05-05 11:02:20,855 [DEBUG] kdev:   nodocker = False
2024-05-05 11:02:20,855 [DEBUG] kdev:   mrproper = False
2024-05-05 11:02:20,855 [DEBUG] kdev:   rclocal = /kernel/linux-6.git-build-x86_64/rclocal
2024-05-05 11:02:20,855 [INFO] kdev: -> Step check environment
2024-05-05 11:02:20,855 [INFO] kdev: Target arch = [ x86_64 ]
2024-05-05 11:02:20,855 [INFO] kdev: workdir : /kernel/linux-6.git-build-x86_64
2024-05-05 11:02:20,855 [INFO] kdev: Check /kernel/linux-6.git ok! It's kernel source directory.
2024-05-05 11:02:20,855 [INFO] kdev: -> Exe cmd:make kernelversion
2024-05-05 11:02:20,879 [INFO] kdev: kernel version : 6.8.4
2024-05-05 11:02:20,880 [INFO] kdev: master version : 6
2024-05-05 11:02:20,880 [INFO] kdev: using qcow2 from config
2024-05-05 11:02:20,880 [INFO] kdev: -> Exe cmd:virsh domstate kdev-linux6
2024-05-05 11:02:20,899 [INFO] kdev: -> Exe cmd:virsh destroy kdev-linux6
2024-05-05 11:02:20,915 [INFO] kdev: STDERR error: Failed to destroy domain 'kdev-linux6'
error: Requested operation is not valid: domain is not running
2024-05-05 11:02:20,916 [INFO] kdev:  destroy vm kdev-linux6 failed!
2024-05-05 11:02:20,916 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:20,985 [INFO] kdev: -> Exe cmd:qemu-nbd --disconnect /dev/nbd6
2024-05-05 11:02:20,991 [INFO] kdev: STDOUT /dev/nbd6 disconnected
2024-05-05 11:02:20,992 [DEBUG] kdev: try umount nbd /dev/nbd6
2024-05-05 11:02:20,992 [INFO] kdev: -> Exe cmd:qemu-nbd --connect /dev/nbd6 /kernel/linux-6.git-build-x86_64/rootfs.qcow2
2024-05-05 11:02:21,046 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:21,056 [INFO] kdev: -> Exe cmd:mount -o rw /dev/nbd6p1 /tmp/qcow2-3097
2024-05-05 11:02:21,067 [INFO] kdev: STDERR mount: /tmp/qcow2-3097: wrong fs type, bad option, bad superblock on /dev/nbd6p1, missing codepage or helper program, or other error.
2024-05-05 11:02:21,067 [INFO] kdev: Mount qcow2 /dev/nbd6p1 failed! Try again.
2024-05-05 11:02:21,067 [INFO] kdev: -> Exe cmd:mount -o rw /dev/nbd6p2 /tmp/qcow2-3097
2024-05-05 11:02:21,090 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:21,102 [INFO] kdev:  run cmd: /usr/bin/cp -a /kernel/linux-6.git-build-x86_64/boot/config-6.8.4+ /kernel/linux-6.git-build-x86_64/boot/vmlinuz-6.8.4+ /kernel/linux-6.git-build-x86_64/boot/System.map-6.8.4+ /tmp/qcow2-3097/boot/
2024-05-05 11:02:21,102 [INFO] kdev: -> Exe cmd:/usr/bin/cp -a /kernel/linux-6.git-build-x86_64/boot/config-6.8.4+ /kernel/linux-6.git-build-x86_64/boot/vmlinuz-6.8.4+ /kernel/linux-6.git-build-x86_64/boot/System.map-6.8.4+ /tmp/qcow2-3097/boot/
2024-05-05 11:02:21,490 [INFO] kdev:  copy vmlinuz/config ok! /tmp/qcow2-3097/boot
2024-05-05 11:02:21,490 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:21,956 [INFO] kdev: -> Exe cmd:/usr/bin/cp -a /kernel/linux-6.git-build-x86_64/lib/modules/6.8.4+ /tmp/qcow2-3097/lib/modules/
2024-05-05 11:02:44,476 [INFO] kdev:  copy modules(stripped) ok! /tmp/qcow2-3097/lib/modules
2024-05-05 11:02:44,477 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:44,586 [INFO] kdev: -> Exe cmd:/usr/bin/cp -a /kernel/linux-6.git-build-x86_64/usr/src /tmp/qcow2-3097/usr/
2024-05-05 11:02:45,777 [INFO] kdev:  copy headers ok! /tmp/qcow2-3097/usr
2024-05-05 11:02:45,777 [INFO] kdev: -> Exe cmd:sync
2024-05-05 11:02:45,838 [INFO] kdev:  set hostname : kdev
2024-05-05 11:02:45,843 [INFO] kdev: using custom rclocal from config
2024-05-05 11:02:45,844 [INFO] kdev:  set rc.local done!
2024-05-05 11:02:45,844 [INFO] kdev:  clean ...
2024-05-05 11:02:45,844 [INFO] kdev: -> Exe cmd:umount -l /tmp/qcow2-3097
2024-05-05 11:02:46,049 [INFO] kdev: -> Exe cmd:qemu-nbd --disconnect /dev/nbd6
2024-05-05 11:02:46,057 [INFO] kdev: STDOUT /dev/nbd6 disconnected
2024-05-05 11:02:46,057 [INFO] kdev: -> handle_rootfs Done! Ret=[ 0 ] Runtime=[ 0.420 min ]
2024-05-05 11:02:46,058 [INFO] kdev: -> Repeat Build Options [/usr/bin/kdev rootfs]

```


## kdev run

```
[root@X99F8D /linux/linux-6.git-build-x86_64]# kdev run
2024-05-05 11:05:29,811 [DEBUG] kdev: Enable debug output
2024-05-05 11:05:29,812 [DEBUG] kdev: Parser and config:
2024-05-05 11:05:29,812 [DEBUG] kdev:   version = False
2024-05-05 11:05:29,812 [DEBUG] kdev:   help = False
2024-05-05 11:05:29,812 [DEBUG] kdev:   verbose = None
2024-05-05 11:05:29,812 [DEBUG] kdev:   sourcedir = /kernel/linux-6.git
2024-05-05 11:05:29,812 [DEBUG] kdev:   arch = x86_64
2024-05-05 11:05:29,812 [DEBUG] kdev:   workdir = None
2024-05-05 11:05:29,812 [DEBUG] kdev:   debug = True
2024-05-05 11:05:29,812 [DEBUG] kdev:   name = None
2024-05-05 11:05:29,812 [DEBUG] kdev:   vmcpu = None
2024-05-05 11:05:29,812 [DEBUG] kdev:   vmram = None
2024-05-05 11:05:29,812 [DEBUG] kdev:   func = <function timer.<locals>.wrapper at 0x7f8ecd71fc10>
2024-05-05 11:05:29,812 [DEBUG] kdev:   nbd = nbd6
2024-05-05 11:05:29,812 [DEBUG] kdev:   skipimagecheck = True
2024-05-05 11:05:29,812 [DEBUG] kdev:   vmname = kdev-linux6
2024-05-05 11:05:29,813 [DEBUG] kdev:   config = ubuntu24_x86_64_defconfig
2024-05-05 11:05:29,813 [DEBUG] kdev:   nodocker = False
2024-05-05 11:05:29,813 [DEBUG] kdev:   mrproper = False
2024-05-05 11:05:29,813 [DEBUG] kdev:   rclocal = /kernel/linux-6.git-build-x86_64/rclocal
2024-05-05 11:05:29,813 [DEBUG] kdev:   qcow2_image = /linux/linux-6.git-build-x86_64/rootfs.qcow2
2024-05-05 11:05:29,813 [INFO] kdev: -> Step check environment
2024-05-05 11:05:29,813 [INFO] kdev: Target arch = [ x86_64 ]
2024-05-05 11:05:29,813 [INFO] kdev: workdir : /kernel/linux-6.git-build-x86_64
2024-05-05 11:05:29,813 [INFO] kdev: Check /kernel/linux-6.git ok! It's kernel source directory.
2024-05-05 11:05:29,813 [INFO] kdev: -> Exe cmd:make kernelversion
2024-05-05 11:05:29,838 [INFO] kdev: kernel version : 6.8.4
2024-05-05 11:05:29,838 [INFO] kdev: master version : 6
2024-05-05 11:05:29,839 [INFO] kdev: virt-install is found in the system at /usr/bin/virt-install.
2024-05-05 11:05:29,839 [INFO] kdev: using qcow2 from config
2024-05-05 11:05:29,839 [INFO] kdev:  try startup kdev-linux6
2024-05-05 11:05:29,839 [INFO] kdev: -> Exe cmd:virsh domstate kdev-linux6
2024-05-05 11:05:29,857 [INFO] kdev: -> Exe cmd:virsh start kdev-linux6
2024-05-05 11:05:31,537 [INFO] kdev: STDOUT Domain 'kdev-linux6' started
2024-05-05 11:05:31,539 [INFO] kdev: start vm kdev-linux6 ok, enjoy it.
Connected to domain 'kdev-linux6'
Escape character is ^] (Ctrl + ])

                             GNU GRUB  version 2.12

 +----------------------------------------------------------------------------+
 | Ubuntu                                                                     |
 |*Advanced options for Ubuntu                                                |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 +----------------------------------------------------------------------------+

      Use the ^ and v keys to select which entry is highlighted.          
      Press enter to boot the selected OS, `e' to edit the commands       
      before booting or `c' for a command-line.                           

```







## 其他

### 待适配发行版信息

* [Debian] (docs/Debian.md)
* [CentOS] (docs/CentOS.md)
* [RockyLinux] (docs/RockyLinux.md)





















---
