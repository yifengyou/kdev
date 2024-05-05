# kdev (linux kernel development tools)

```
Something I hope you know before go into the coding~
First, please watch or star this repo, I'll be more happy if you follow me.
Bug report, questions and discussion are welcome, you can post an issue or pull a request.
```

## 项目描述

本仓库提供kdev工具，用于快速构建内核编译环境、测试环境（QEMU/KVM）。

1. 使用Docker容器编译内核，规避编译环境差异（gcc，dwarves，pythn3，etc...）
2. 使用Qemu-kvm虚机运行内核
3. 适配linux 2/3/4/5/6内核版本，发行版默认使用Ubuntu

| Ubuntu 版本及代号                        | 内核版本  |
| ---------------------------------------- | --------- |
| Ubuntu 24.04.X **LTS** (Jammy Jellyfish) | 6.8.4     |
| Ubuntu 22.04.X **LTS** (Jammy Jellyfish) | 5.15.60   |
| Ubuntu 18.04.X **LTS** (Bionic Beaver)   | 4.15.18   |
| Ubuntu 14.04.5 **LTS** (Trusty Tahr)     | 3.13.11   |
| Ubuntu 10.04.X **LTS** (Lucid Lynx)      | 2.6.32.63 |


## 极速入门

0. 获取内核代码

1. 编译内核

```
kdev kernel
```

2. 构建rootfs

```
kdev rootfs
```

3. 运行

```
kdev run
```




## TODO

1. 增加KGDB支持
2. 增加CentOS系列发行版支持
3. ...



## 其他

### 待适配发行版信息

* [Debian] (docs/Debian.md)
* [CentOS] (docs/CentOS.md)
* [RockyLinux] (docs/RockyLinux.md)

















































---
