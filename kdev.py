#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
 Authors:
   yifengyou <842056007@qq.com>
"""

import os
import random
import shutil
import subprocess
import sys
import argparse

CURRENT_VERSION = "0.2.0"

KERNEL_BUILD_MAP = {
    "linux-1.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux1.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img"
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-2.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux2.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img"
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-3.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux3.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                        "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-arm64-uefi1.img",
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-4.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux4.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img"
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/buster/latest/debian-10-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-arm64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-10-nocloud-arm64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-5.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux5.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-arm64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-11-nocloud-arm64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-6.0": {
        "docker": [
            "dockerproxy.com/yifengyou/linux6.0:latest"
        ],
        "config": {
            "x86_64": [],
            "arm64": [],
        },
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-arm64-disk1.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-arm64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                }
            }
    }
}


def find_docker_img(args):
    return None


def check_python_version():
    current_python = sys.version_info[0]
    if current_python == 3:
        return
    else:
        raise Exception('Invalid python version requested: %d' % current_python)


def check_privilege():
    if os.getuid() == 0:
        return
    else:
        print("superuser root privileges are required to run")
        print(f"  sudo kdev {' '.join(sys.argv[1:])}")
        sys.exit(1)


def check_arch(args):
    print(" -> Step check environment")
    if args.arch:
        if args.arch == "x86_64":
            print("The args.arch is x86_64")
        elif args.arch == "arm64":
            print("The args.arch is arm64")
        else:
            print(f"Unsupported arch {args.arch}", file=sys.stderr)
            sys.exit(1)
    else:
        args.arch = os.uname().machine
        print(f"The args.arch is {args.arch} (auto-detect)")


def check_src_hugefile(args):
    # github不支持直接推送100M+文件，尽量不要大文件
    ret = do_exe_cmd(["find", args.sourcedir, "-name", ".git", "-prune", "-type", "f", "-size", "+100M"],
                     capture_output=True, text=True)
    if ret == 0:
        print("Warnning!find file large than 100MB")


def check_docker_image(args):
    linux_version = "linux-%s.0" % args.masterversion
    try:
        docker_img_list = KERNEL_BUILD_MAP[linux_version]["docker"]
    except KeyError:
        return False, ''
    if len(docker_img_list) == 0:
        return False, ''
    return True, docker_img_list[0]


def check_qcow_image(args):
    linux_version = "linux-%s.0" % args.masterversion
    try:
        qcow_img_list = KERNEL_BUILD_MAP[linux_version]["image"][args.arch]
    except KeyError:
        return False, ''
    if "debian" in qcow_img_list and len(qcow_img_list["debian"]) != 0:
        return True, qcow_img_list["debian"][0]
    elif "ubuntu" in qcow_img_list and len(qcow_img_list["ubuntu"]) != 0:
        return True, qcow_img_list["ubuntu"][0]
    elif "centos" in qcow_img_list and len(qcow_img_list["centos"]) != 0:
        return True, qcow_img_list["centos"][0]
    elif "fedora" in qcow_img_list and len(qcow_img_list["fedora"]) != 0:
        return True, qcow_img_list["fedora"][0]
    return False, ''


def do_exe_cmd(cmd, enable_log=False, logfile="kernel.txt", capture_output=True, print_output=False, shell=False):
    output = ''
    if isinstance(cmd, str):
        cmd = cmd.split()
    elif isinstance(cmd, list):
        pass
    else:
        raise Exception("unsupported type when run do_exec_cmd", type(cmd))
    if enable_log:
        log_file = open(logfile, "a")
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=shell)

    while True:
        line = p.stdout.readline()
        if not line:
            break
        line = line.decode("utf-8").strip()
        if print_output == True:
            print(line)
        if enable_log:
            log_file.write(line + "\n")
        output += line + '\n'

    if enable_log:
        log_file.close()
    return_code = p.wait()
    return return_code, output


def perror(str):
    print("Error: ", str)
    sys.exit(1)


def pwarn(str):
    print("Warn: ", str)


def handle_check(args):
    check_arch(args)
    if not args.workdir:
        args.workdir = os.getcwd()
    print(f"workdir : {args.workdir}")

    if args.sourcedir:
        if not os.path.isdir(args.sourcedir):
            print(f"dir {args.sourcedir} does't exists!")
            sys.exit(1)
    else:
        args.sourcedir = os.getcwd()
        print(f"sourcedir is {args.sourcedir}")

    if os.path.isfile(os.path.join(args.sourcedir, "Makefile")) and \
            os.path.isfile(os.path.join(args.sourcedir, "Kbuild")):
        print(f"Check {args.sourcedir} ok! It's kernel source directory.")
    else:
        print(f"Check {args.sourcedir} failed! It's not a kernel source directory.")
        sys.exit(1)

    os.chdir(args.sourcedir)
    ret, kernelversion = do_exe_cmd("make kernelversion")
    if ret != 0:
        perror(f"Unsupported {kernelversion}")

    args.kernelversion = kernelversion.strip()
    print(f"kernel version : {args.kernelversion}")

    args.masterversion = args.kernelversion[0]
    if args.masterversion not in [str(i) for i in range(1, 7)]:
        perror("unsupoorted masterversion", args.masterversion)
    print(f"master version : {args.masterversion}")

    print("check all ok!")


def handle_kernel(args):
    handle_check(args)
    print(" -> Step build kernel")
    os.chdir(args.workdir)

    # 生产编译脚本，因为不同环境对python版本有依赖要求，暂时不考虑规避，脚本万能
    body = """
    
## body

echo "run body"

cd ${SOURCEDIR}

mkdir -p ${WORKDIR}/build || :
make O=${WORKDIR}/build mrproper
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} debian_${ARCH}_defconfig

if [ $? -ne 0 ]; then
    echo "make debian_${ARCH}_defconfig failed!"
    exit 1
fi
ls -alh ${WORKDIR}/build/.config
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j "${JOB}"
if [ $? -ne 0 ]; then
    echo "Build kernel binary failed!"
    exit 1
fi

echo " kernel install to ${WORKDIR}/boot"
if [ ! -d "${WORKDIR}/boot" ]; then
    mkdir -p ${WORKDIR}/boot
fi
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install INSTALL_PATH=${WORKDIR}/boot
if [ $? -ne 0 ]; then
    echo "make install to ${WORKDIR}/boot failed!"
    exit 1
fi

echo " kernel modules install to ${WORKDIR}"
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOB} INSTALL_MOD_PATH=${WORKDIR}
if [ $? -ne 0 ]; then
    # try again
    make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOB} INSTALL_MOD_PATH=${WORKDIR}
    if [ $? -ne 0 ]; then
        echo "make modules_install to ${WORKDIR} failed!"
        exit 1
    fi
fi

cd ${SOURCEDIR}
KERNELRELEASE=$( make -s --no-print-directory O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} kernelrelease 2>/dev/null )
KERNEL_HEADER_INSTALL=${WORKDIR}/usr/src/linux-headers-${KERNELRELEASE}
echo " kernel headers install to ${KERNEL_HEADER_INSTALL}"
if [ ! -d "${KERNEL_HEADER_INSTALL}" ]; then
    mkdir -p ${KERNEL_HEADER_INSTALL}
fi
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_install INSTALL_HDR_PATH=${KERNEL_HEADER_INSTALL}
if [ $? -ne 0 ]; then
    echo "make headers_install to ${WORKDIR} failed!"
    exit 1
fi

"""

    if args.nodocker:
        print("build kernel in host")

        args.cross_compile = ''
        if os.uname().machine != args.arch:
            if args.arch == "arm64":
                args.cross_compile = "aarch64-linux-gnu-"

        head = """
#!/bin/bash

if [ -f /.dockerenv ]; then
    echo "should run in host, not in docker"
    exit 1
fi

WORKDIR=%s
SOURCEDIR=%s
ARCH=%s
CROSS_COMPILE=%s
KERNEL_HEADER_INSTALL=%s
JOB=%s
""" % (
            args.workdir,
            args.sourcedir,
            args.arch,
            args.cross_compile,
            args.kernelversion,
            args.job,

        )
        with open("build_in_host.sh", "w") as script:
            script.write(head + body)

        os.chmod("build_in_host.sh", 0o755)
        host_cmd = "/bin/bash build_in_host.sh"
        print("run host build cmd:", host_cmd)
        ret, output = do_exe_cmd(host_cmd, print_output=True)
        if ret != 0:
            perror("host build failed!")
        print("host build ok with 0 retcode")
    else:
        print("build kernel in docker")
        ok, image = check_docker_image(args)
        if not ok:
            perror("not useable docker image found!")
        print(f" using docker image : {image} ")
        args.docker_image = image

        args.cross_compile = ''
        if os.uname().machine != args.arch:
            if args.arch == "arm64":
                args.cross_compile = "aarch64-linux-gnu-"

        head = """#!/bin/bash
set -x

if [ ! -f /.dockerenv ]; then
    echo "should run in docker, not in host"
    exit 1
fi

WORKDIR=%s
SOURCEDIR=%s
ARCH=%s
CROSS_COMPILE=%s
KERNEL_HEADER_INSTALL=%s
JOB=%s

""" % (
            "/work",
            "/kernel",
            args.arch,
            args.cross_compile,
            args.kernelversion,
            args.job,
        )
        with open("build_in_docker.sh", "w") as script:
            script.write(head + body)
        os.chmod("build_in_docker.sh", 0o755)
        docker_cmd = f"docker run -t " \
                     f" -v {args.workdir}/build_in_docker.sh:/bin/kdev  " \
                     f" -v {args.sourcedir}:/kernel  " \
                     f" -v {args.workdir}:/workdir  " \
                     f" -w /workdir  " \
                     f"{args.docker_image} " \
                     f"/bin/kdev"
        print("run docker build cmd:", docker_cmd)
        ret, output = do_exe_cmd(docker_cmd, print_output=True)
        if ret != 0:
            perror("docker build failed!")
        print("docker build ok with 0 retcode")


def handle_rootfs(args):
    handle_check(args)
    ok, image_url = check_qcow_image(args)
    if not ok:
        perror(" no available image found!")
    print(f" using qcows url {image_url}")

    args.qcow2_url = image_url
    args.qcow2 = os.path.basename(image_url)
    print(f" qcow2 name : {args.qcow2}")
    os.chdir(args.workdir)
    if not os.path.isfile(args.qcow2):
        print(f" start to download {args.qcow2_url}")
        do_exe_cmd(["wget", "-c", args.qcow2_url], print_output=True)
    else:
        print(f" already exists {args.qcow2}, reusing it.")
        do_exe_cmd(["qemu-nbd", "--disconnect", args.qcow2], print_output=True)
        do_exe_cmd(["modprobe", "nbd", "max_part=9"], print_output=True)

    args.nbd = None
    for nbd in ["/dev/nbd" + str(i) for i in range(9)]:
        ret, output = do_exe_cmd(["qemu-nbd", "--connect", nbd, args.qcow2])
        if ret == 0:
            args.nbd = nbd
            break

    if not args.nbd:
        perror("No available nbd found!")

    args.tmpdir = "/tmp/qcow2-" + str(random.randint(0, 9999))
    os.makedirs(args.tmpdir, exist_ok=True)

    do_exe_cmd(["mount", "-o", "rw", args.nbd + "p1", args.tmpdir])
    do_exe_cmd(["ls", args.tmpdir + "/boot/"], print_output=True)

    # 拷贝boot目录，包含linux vmlinuz config maps
    copy_bootdir = os.path.join(args.workdir, "/boot")
    qcow_bootdir = os.path.join(args.tmpdir, "/boot/")
    if os.path.isdir(copy_bootdir) and copy_bootdir != "/boot":
        shutil.copytree(copy_bootdir, qcow_bootdir)
        print(f" copy vmlinuz、config done! {qcow_bootdir}")

    # 拷贝lib目录，包含inbox核外驱动
    copy_libdir = os.path.join(args.workdir, "/lib/modules")
    qcow_libdir = os.path.join(args.tmpdir, "/lib/modules")
    if os.path.isdir(copy_libdir) and copy_libdir != "/lib/modules":
        shutil.copytree(copy_libdir, qcow_libdir)
        print(f" copy modules(stripped) done! {qcow_libdir}")

    # 拷贝内核头文件
    copy_headerdir = os.path.join(args.workdir, "/usr")
    qcow_headerdir = os.path.join(args.tmpdir, "/usr")
    if os.path.isdir(copy_headerdir) and copy_headerdir != "/usr":
        shutil.copytree(copy_headerdir, qcow_headerdir)
        print(f" copy headers done! {qcow_headerdir}")

    # 设置主机名
    args.hostname = args.qcow2.split(".")[0]
    qcow_hostname = os.path.join(args.tmpdir, "/etc/hostname")
    with open(qcow_hostname, "w") as f:
        f.write(args.hostname)
    print(f" set hostname : {args.hostname}")

    # 检查cloud-init变关闭
    qcow_cloudinitdir = os.path.join(args.tmpdir, "/etc/cloud")
    if os.path.isdir(qcow_cloudinitdir):
        with open(os.path.join(args.tmpdir, "cloud-init.disabled"), "w") as f:
            f.write("")
    if os.path.isfile(args.tmpdir + "/usr/bin/cloud-*"):
        os.remove(args.tmpdir + "/usr/bin/cloud-*")

    # 写入初始化脚本，开机第一次执行
    with open(os.path.join(args.tmpdir, "/etc/firstboot"), "w") as f:
        f.write("")
    with open(os.path.join(args.tmpdir, "/etc/rc.local"), "w") as f:
        f.write("""#!/bin/bash

if [ -f /etc/firstboot ]; then
	rm -f /etc/firstboot
	cd /boot
	for k in $(ls vmlinuz-*); do
		KERNEL=${k//vmlinuz-/}
		update-initramfs -k ${KERNEL} -c
	done
	if which update-grub2 &> /dev/null ; then
	    update-grub2
	fi
	sync
	if which chpasswd &> /dev/null ; then
		echo root:linux | chpasswd
	elif which passwd &> /dev/null ; then
		echo linux | passwd -stdin root
	else
		echo "can't reset root passwd"
	fi
	if [ -d /etc/cloud/ ]; then
		touch /etc/cloud/cloud-init.disabled
		rm -f /usr/bin/cloud-*
	fi
	if which ssh-keygen &> /dev/null ; then
	    ssh-keygen -A
	fi
	sync
	reboot -f
fi

exit 0

""")
    os.chmod(os.path.join(args.tmpdir, "/etc/rc.local"), 0o755)
    print(" set rc.local done!")

    print(" clean ...")
    do_exe_cmd(f"umount -l {args.tmpdir}")
    do_exe_cmd(f"qemu-nbd --disconnect {args.nbd}")
    os.rmdir(args.tmpdir)
    print(" handle rootfs done!")


def handle_run(args):
    handle_check(args)
    if args.arch == "x86_64":
        args.qemuapp = "qemu-system-x86_64"
    elif args.arch == "arm64":
        args.qemuapp = "qemu-system-aarch64"
    else:
        perror(f"unsupported arch {args.arch}")

    path = shutil.which(args.qemuapp)
    # 判断路径是否为None，输出结果
    if path is None:
        print(f"{args.qemuapp} is not found in the system.")
        print("")
    else:
        print(f"{args.qemuapp} is found in the system at {path}.")

    path = shutil.which("virsh")
    # 判断路径是否为None，输出结果
    if path is None:
        print(f"virsh is not found in the system.")
        print("")
    else:
        print(f"virsh is found in the system at {path}.")

    # 检查是否有可用的QCOW2文件
    ok, image_url = check_qcow_image(args)
    if not ok:
        perror(" no available image found!")
    print(f" using qcows url {image_url}")

    args.qcow2_url = image_url
    args.qcow2 = os.path.basename(image_url)
    print(f" qcow2 name : {args.qcow2}")

    os.chdir(args.workdir)
    if not os.path.isfile(args.qcow2):
        print(" no qcow2 found!")
        print("Tips: run `kdev rootfs`")
        sys.exit(1)
    else:
        print(f" found qcow2 {args.qcow2} in workdir, using it.")

    if not args.name:
        args.name = f"linux-{args.masterversion}-{args.arch}"

    print(f" try startup {args.name}")
    retcode, args.vmstat = do_exe_cmd(f"virsh domstate {args.name}", print_output=False)
    if 0 == retcode:
        if args.vmstat.strip() == "running":
            print(f"{args.name} already running")
            return
        ret, _ = do_exe_cmd(f"virsh start {args.name}", print_output=True)
        if 0 == ret:
            print(f"start vm {args.name} ok, enjoy it.")
        else:
            perror(f"start vm {args.name} failed,check it.")
        sys.exit(0)

    print(f" {args.name} does't exists! create new vm")

    if args.arch == "x86_64":
        args.vmarch = "x86_64"
        if not args.vmcpu:
            args.vmcpu = "8"
        if not args.vmram:
            args.vmram = "8192"
    elif args.arch == "arm64":
        args.vmarch = "aarch64"
        if not args.vmcpu:
            args.vmcpu = "2"
        if not args.vmram:
            args.vmram = "4096"
    else:
        perror(f"unsupported arch {args.arch}")

    qemu_cmd = f"virt-install " \
               f"  --name {args.name}" \
               f"  --arch {args.vmarch}" \
               f"  --ram {args.vmram}" \
               f"  --os-type=linux" \
               f"  --video=vga" \
               f"  --vcpus {args.vmcpu} " \
               f"  --disk path={os.path.join(args.workdir, args.qcow2)},format=qcow2,bus=scsi" \
               f"  --network bridge=br0,virtualport_type=openvswitch" \
               f"  --import" \
               f"  --graphics spice,listen=0.0.0.0" \
               f"  --noautoconsole"

    retcode, _ = do_exe_cmd(qemu_cmd, print_output=True)
    if 0 == retcode:
        print(f" start {args.name} success! enjoy it~~")
    else:
        print(f" start {args.name} failed!")


def handle_clean(args):
    handle_check(args)


def main():
    check_python_version()

    # 顶层解析
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-v", "--version", action="store_true", help="show program's version number and exit")
    parser.add_argument("-h", "--help", action="store_true", help="show this help message and exit")
    subparsers = parser.add_subparsers()

    # 定义base命令用于集成
    parent_parser = argparse.ArgumentParser(add_help=False, description="kdev - a tool for kernel development")
    parent_parser.add_argument("-V", "--verbose", action="store_true", help="show verbose output")
    parent_parser.add_argument("-s", "--sourcedir", help="set kernel source dir")
    parent_parser.add_argument("-a", "--arch", help="set arch, default is x86_64")
    parent_parser.add_argument("-w", "--workdir", help="setup workdir")
    parent_parser.add_argument('-l', '--log', default='/var/log/kdev.log')
    parent_parser.add_argument('-d', '--daemon', action='store_true')

    # 添加子命令 check
    parser_check = subparsers.add_parser('check', parents=[parent_parser])
    parser_check.add_argument("-i", "--aptinstall", action="store_true", help="install dependency packages")
    parser_check.set_defaults(func=handle_check)

    # 添加子命令 kernel
    parser_kernel = subparsers.add_parser('kernel', parents=[parent_parser])
    parser_kernel.add_argument("--nodocker", action="store_true", help="build kernel without docker environment")
    parser_kernel.add_argument("-j", "--job", default=os.cpu_count(), help="setup compile job number")
    parser_kernel.add_argument("-c", "--clean", help="clean docker when exit")
    parser_kernel.set_defaults(func=handle_kernel)

    # 添加子命令 rootfs
    parser_rootfs = subparsers.add_parser('rootfs', parents=[parent_parser])
    parser_rootfs.add_argument('-r', '--release', action='store_true')
    parser_rootfs.set_defaults(func=handle_rootfs)

    # 添加子命令 run
    parser_run = subparsers.add_parser('run', parents=[parent_parser])
    parser_run.add_argument('-n', '--name', help="setup vm name")
    parser_run.add_argument('--vmcpu', help="setup vm vcpu number")
    parser_run.add_argument('--vmram', help="setup vm ram")
    parser_run.set_defaults(func=handle_run)
    args = parser.parse_args()

    # 添加子命令 clean
    parser_clean = subparsers.add_parser('clean', parents=[parent_parser])
    parser_clean.add_argument('--name', help="clean vm (destroy/undefine)")
    parser_clean.add_argument('--qcow', help="delete qcow")
    parser_clean.set_defaults(func=handle_clean)

    # 开始解析命令
    args = parser.parse_args()

    if args.version:
        print("kdev %s" % CURRENT_VERSION)
        sys.exit(0)
    elif args.help or len(sys.argv) < 2:
        parser.print_help()
        sys.exit(0)
    else:
        args.func(args)


if __name__ == "__main__":
    main()
