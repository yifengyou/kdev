# ubuntu

## 支持情况

| ubuntu版本、代号         | 内核版本  |   支持架构情况    | docker支持情况 |  debootstrap支持情况 |
| ---                    | ---      |     ---          |  ---         |    ---              |
| ubuntu 10.04(lucid)    | 2.6.32   |  i368、x86_64    |  不支持       |    无法现代环境运行   |
| ubuntu 14.04(trusty)   | 3.13.11  |  x86_64、aarch64 |  有限支持     |     支持            |
| ubuntu 18.04(bionic)   | 4.15.18  |  x86_64、aarch64 |  支持        |      支持           |
| ubuntu 22.04(jammy)    | 5.15.60  |  x86_64、aarch64 |  支持        |      支持           |
| ubuntu 24.04(nobel)    | 6.8.4    |  x86_64、aarch64 |  支持        |       支持          |

## ubuntu kernel

```
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/lucid    ubuntu-10.04-lucid.git
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/trusty   ubuntu-14.04-trusty.git
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/bionic   ubuntu-18.04-bionic.git
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/focal    ubuntu-20.04-focal.git
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/noble    ubuntu-24.04-noble.git
git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/lunar    ubuntu-22.04-lunar.git
```




---
