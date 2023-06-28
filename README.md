# kdev (linux kernel development tools)

```
Something I hope you know before go into the coding~
First, please watch or star this repo, I'll be more happy if you follow me.
Bug report, questions and discussion are welcome, you can post an issue or pull a request.
```


## Debian Distribution Release

| 版本及代号                     | 内核版本                 | 稳定性                                           | 可用仓库                                                                           |
| ------------------------------ | ------------------------ | ------------------------------------------------ | ---------------------------------------------------------------------------------- |
| **Debian 12 (bookworm)**           | 6.1/5.10(LTS)/5.15       | 当前的稳定（stable）版                           | [链接](http://mirrors.tencent.com/debian/dists/bookworm/)                          |
| **Debian 11 (bullseye)**           | 5.10(LTS)                | 当前的旧的稳定（oldstable）版                    | [链接](http://mirrors.tencent.com/debian/dists/bullseye/)                          |
| **Debian 10（buster）**            | 4.19/4.20                | 当前的更旧的稳定（oldoldstable）版，现有长期支持   | [链接](http://mirrors.tencent.com/debian/dists/buster/)                            |
| Debian 9（stretch）            | 4.9/4.10                 | 已存档版本，现有扩展长期支持                      | [链接](https://snapshot.debian.org/archive/debian/20220101T024315Z/dists/stretch/) |
| **Debian 8（jessie）**             | 3.16/3.18                | 已存档版本，现有扩展长期支持                      | [链接](http://snapshot.debian.org/archive/debian/20210326T030000Z/dists/jessie)    |
| Debian 7（wheezy）             | 3.2/3.4                  | 被淘汰的稳定版                                   | [链接](http://snapshot.debian.org/archive/debian/20210326T030000Z/dists/wheezy)    |
| **Debian 6.0（squeeze）**         | 2.6.32/2.6.36/2.6.38/3.2 | 被淘汰的稳定版                                   | [链接](https://snapshot.debian.org/archive/debian/20160301T103342Z/dists/squeeze/) |
| Debian GNU/Linux 5.0（lenny）  | 2.6.26                   | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 4.0（etch）   | 2.6.18                   | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 3.1（sarge）  | 2.4.27/2.6.8             | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 3.0（woody）  | 2.4.18/2.6.8             | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 2.2（potato） | 2.2.10/2.4.18            | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 2.1（slink）  | 2.0.34/2.2.10            | 被淘汰的稳定版                                   |                                                                                    |
| Debian GNU/Linux 2.0（hamm）   | 2.0.30/2.0.36            | 被淘汰的稳定版                                   |                                                                                    |

* 存档镜像: <https://snapshot.debian.org/>


## Ubuntu Distribution Release

| 版本及代号                                | 内核版本 | 稳定性 | 可用仓库                                                                                                                                                                                                 |
| ----------------------------------------- | -------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ubuntu 22.04.X **LTS** (Jammy Jellyfish)  | 5.15     |        | [QCOW2](http://cloud-images-archive.ubuntu.com/releases/jammy/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/jammy/) / [ISO](https://old-releases.ubuntu.com/releases/jammy/)                        |
| Ubuntu 21.10 (Impish Indri)               | 5.14     |        |                                                                                                                                                                                                          |
| Ubuntu 21.04 (Hirsute Hippo)              | 5.11     |        |                                                                                                                                                                                                          |
| Ubuntu 20.10 (Groovy Gorilla)             | 5.8      |        |                                                                                                                                                                                                          |
| Ubuntu 20.04.X **LTS** (Focal Fossa)      | 5.4      |        | [QCOW2](http://cloud-images-archive.ubuntu.com/releases/focal/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/focal/) / [ISO](https://old-releases.ubuntu.com/releases/focal/)                        |
| Ubuntu 19.10 (Eoan Ermine)                | 5.2      |        |                                                                                                                                                                                                          |
| Ubuntu 19.04 (Disco Dingo)                | 5.0      |        |                                                                                                                                                                                                          |
| Ubuntu 18.10 (Cosmic Cuttlefish)          | 4.18     |        |                                                                                                                                                                                                          |
| Ubuntu 18.04.X **LTS** (Bionic Beaver)    | 4.15     |        | [QCOW2](http://cloud-images-archive.ubuntu.com/releases/bionic/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/bionic/) / [ISO](https://old-releases.ubuntu.com/releases/bionic/)                     |
| Ubuntu 17.10 (Artful Aardvark)            | 4.13     |        |                                                                                                                                                                                                          |
| Ubuntu 17.04 (Zesty Zapus)                | 4.10     |        |                                                                                                                                                                                                          |
| Ubuntu 16.10 (Yakkety Yak)                | 4.8      |        |                                                                                                                                                                                                          |
| Ubuntu 16.04.X **LTS** (Xenial Xerus)     | 4.4      |        | [QCOW2](http://cloud-images-archive.ubuntu.com/releases/xenial/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/xenial/) / [ISO](https://old-releases.ubuntu.com/releases/xenial/)                     |
| Ubuntu 15.10 (Wily Werewolf)              | 4.2      |        |                                                                                                                                                                                                          |
| Ubuntu 15.04 (Vivid Vervet)               | 3.19     |        |                                                                                                                                                                                                          |
| Ubuntu 14.10 (Utopic Unicorn)             | 3.16     |        |                                                                                                                                                                                                          |
| Ubuntu 14.04.5 **LTS** (Trusty Tahr)      | 3.13     |        | [QCOW2](http://cloud-images.ubuntu.com/releases/trusty/release/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/trusty/) / [ISO](https://old-releases.ubuntu.com/releases/trusty/)                     |
| Ubuntu 13.10 (Saucy Salamander)           | 3.11     |        |                                                                                                                                                                                                          |
| Ubuntu 13.04 (Raring Ringtail)            | 3.8      |        |                                                                                                                                                                                                          |
| Ubuntu 12.10 (Quantal Quetzal)            | 3.5      |        |                                                                                                                                                                                                          |
| Ubuntu 12.04.X **LTS** (Precise Pangolin) | 3.2      |        | [QCOW2](http://cloud-images.ubuntu.com/releases/precise/release/) / [APT源](http://archive.ubuntu.com/ubuntu/dists/precise/) / [ISO](https://old-releases.ubuntu.com/releases/precise/)                  |
| Ubuntu 11.10 (Oneiric Ocelot)             | 3.0      |        |                                                                                                                                                                                                          |
| Ubuntu 11.04 (Natty Narwhal)              | 2.6.38   |        |                                                                                                                                                                                                          |
| Ubuntu 10.10 (Maverick Meerkat)           | 2.6.35   |        |                                                                                                                                                                                                          |
| Ubuntu 10.04.X **LTS** (Lucid Lynx)       | 2.6.32   |        | [QCOW2](http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/) / [APT源](https://old-releases.ubuntu.com/ubuntu/dists/lucid/) / [ISO](https://old-releases.ubuntu.com/releases/lucid/) |
| Ubuntu 9.10 (Karmic Koala)                | 2.6.31   |        |                                                                                                                                                                                                          |
| Ubuntu 9.04 (Jaunty Jackalope)            | 2.6.28   |        |                                                                                                                                                                                                          |
| Ubuntu 8.10 (Intrepid Ibex)               | 2.6.27   |        |                                                                                                                                                                                                          |
| Ubuntu 8.04 (Intrepid Ibex)               | 2.6.24   |        |                                                                                                                                                                                                          |
| Ubuntu 7.10 (Gutsy Gibbon)                | 2.6.22   |        |                                                                                                                                                                                                          |
| Ubuntu 7.04 (Feisty Fawn)                 | 2.6.20   |        |                                                                                                                                                                                                          |
| Ubuntu 6.10 (Edgy Eft)                    | 2.6.17   |        |                                                                                                                                                                                                          |
| Ubuntu 6.06.X **LTS** (Dapper Drake)      | 2.6.15   |        |                                                                                                                                                                                                          |
| Ubuntu 5.10 (Breezy Badger)               | 2.6.12   |        |                                                                                                                                                                                                          |
| Ubuntu 5.04 (Hoary Hedgehog)              | 2.6.10   |        |                                                                                                                                                                                                          |
| Ubuntu 4.10 (Warty Warthog)               | 2.6.8    |        |                                                                                                                                                                                                          |



## CentOS Distribution Release

| 版本及代号            | 内核版本    | 发布日期   | 可用仓库                                                                                                         |
| --------------------- | ----------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| **CentOS Stream 9.0** | 5.14.0-284  | 2021-12-03 | [QCOW2](https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2) |
| **CentOS 8.5**        | 4.18.0-348  | 2021-11-16 |                                                                                                                  |
| CentOS8.4             | 4.18.0-305  | 2021-06-03 | [QCOW2](https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2)  |
| CentOS8.3             | 4.18.0-240  | 2020-12-08 |                                                                                                                  |
| CentOS8.2             | 4.18.0-193  | 2020-06-15 |                                                                                                                  |
| CentOS8.1             | 4.18.0-147  | 2020-01-15 |                                                                                                                  |
| CentOS8.0             | 4.18.0-80   | 2019-09-24 |                                                                                                                  |
| **CentOS 7.9**        | 3.10.0-1160 | 2020-09-29 | [QCOW2](https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2)                             |
| CentOS 7.8            | 3.10.0-1127 | 2020-03-31 |                                                                                                                  |
| CentOS 7.7            | 3.10.0-1062 | 2019-08-06 |                                                                                                                  |
| CentOS 7.6            | 3.10.0-957  | 2018-11-03 |                                                                                                                  |
| CentOS 7.5            | 3.10.0-862  | 2018-04-04 |                                                                                                                  |
| CentOS 7.4            | 3.10.0-693  | 2017-08-03 |                                                                                                                  |
| CentOS 7.3            | 3.10.0-514  | 2016-11-03 |                                                                                                                  |
| CentOS 7.2            | 3.10.0-327  | 2015-11-19 |                                                                                                                  |
| CentOS 7.1            | 3.10.0-229  | 2015-03-31 |                                                                                                                  |
| CentOS 7.0            | 3.10.0-123  | 2014-07-07 |                                                                                                                  |
| **CentOS 6.10**       | 2.6.32-754  | 2018-07-03 | [QCOW2](https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2)                             |
| CentOS 6.9            | 2.6.32-696  | 2017-03-28 |                                                                                                                  |
| CentOS 6.8            | 2.6.32-642  | 2016-05-25 |                                                                                                                  |
| CentOS 6.7            | 2.6.32-573  | 2015-08-07 |                                                                                                                  |
| CentOS 6.6            | 2.6.32-504  | 2014-10-28 |                                                                                                                  |
| CentOS 6.5            | 2.6.32-431  | 2013-12-01 |                                                                                                                  |
| CentOS 6.4            | 2.6.32-358  | 2013-03-09 |                                                                                                                  |
| CentOS 6.3            | 2.6.32-279  | 2012-07-09 |                                                                                                                  |
| CentOS 6.2            | 2.6.32-220  | 2011-12-20 |                                                                                                                  |
| CentOS 6.1            | 2.6.32-131  | 2011-12-09 |                                                                                                                  |
| CentOS 6.0            | 2.6.32-71   | 2011-07-10 |                                                                                                                  |
| CentOS 5.11           | 2.6.18-398  | 2014-09-30 |                                                                                                                  |
| CentOS 5.10           | 2.6.18-371  | 2013-10-19 |                                                                                                                  |
| CentOS 5.9            | 2.6.18-348  | 2013-01-17 |                                                                                                                  |
| CentOS 5.8            | 2.6.18-308  | 2012-03-07 |                                                                                                                  |
| CentOS 5.7            | 2.6.18-274  | 2011-09-13 |                                                                                                                  |
| CentOS 5.6            | 2.6.18-238  | 2011-04-08 |                                                                                                                  |
| CentOS 5.5            | 2.6.18-194  | 2010-05-14 |                                                                                                                  |
| CentOS 5.4            | 2.6.18-164  | 2009-10-21 |                                                                                                                  |
| CentOS 5.3            | 2.6.18-128  | 2009-03-31 |                                                                                                                  |
| CentOS 5.2            | 2.6.18-92   | 2008-06-24 |                                                                                                                  |
| CentOS 5.1            | 2.6.18-53   | 2007-12-02 |                                                                                                                  |
| CentOS 5.0            | 2.6.18-8    | 2007-04-12 |                                                                                                                  |



## RockyLinux Distribution Release


| 版本及代号      | 内核版本       |
| --------------- | -------------- |
| Rocky Linux 9.2 | 6.0            |
| Rocky Linux 9.1 | 5.14.0-70.13.1 |
| Rocky Linux 9.0 | 5.14.0-162.6.1 |
| Rocky Linux 8.5 | 4.18.0-348     |
| Rocky Linux 8.4 | 4.18.0-305     |





















































---
