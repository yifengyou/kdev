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
                     capture_output=True, text=True).stdout.strip()
    if ret == 0:
        print("Warnning!find file large than 100MB")


def check_docker_image(args):
    linux_version = "linux-%s.0" % args.masterversion
    if linux_version in KERNEL_BUILD_MAP:
        if "docker" not in KERNEL_BUILD_MAP[linux_version]:
            return False, ''
        if len(KERNEL_BUILD_MAP[linux_version]["docker"]) == 0:
            return False, ''
        return True, KERNEL_BUILD_MAP[linux_version]["docker"][0]
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
# echo "start do build kernel binary..."
# if [ "`uname -m`" != ${ARCH} ]; then
#     if [ "${ARCH}" == "arm64" ]; then
#         CROSS_COMPILE="aarch64-linux-gnu-"
#     fi
# fi
mkdir -p ${WORKDIR}/build || :
make O=${WORKDIR}/build mrproper
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} debian_${ARCH}_defconfig

if [ $? -ne 0 ]; then
    echo "make debian_${ARCH}_defconfig failed!"
    exit 1
fi
ls -alh ${WORKDIR}/build/.config
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j "${JOBNUM}"
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
make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOBNUM} INSTALL_MOD_PATH=${WORKDIR}
if [ $? -ne 0 ]; then
    # try again
    make O=${WORKDIR}/build ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOBNUM} INSTALL_MOD_PATH=${WORKDIR}
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
JOBNUM=%s
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

        os.chmod("build_in_host.sh", 0o100 | 0o200 | 0o400 | 0o010 | 0o040 | 0o001 | 0o004)
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
JOBNUM=%s
# %s
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
        os.chmod("build_in_docker.sh", 0o100 | 0o200 | 0o400 | 0o010 | 0o040 | 0o001 | 0o004)
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
    if args.arch == "x86_64":
        QCOW2URL = ROOTFS_AMD64_QCOW2[args.masterversion]
    elif args.arch == "arm64":
        QCOW2URL = ROOTFS_ARM64_QCOW2[args.masterversion]
    else:
        print(f"Unsupported arch {args.arch}", file=sys.stderr)
        sys.exit(1)

    if not QCOW2URL:
        print(" no qcow2 support current kernel version")
        sys.exit(1)
    else:
        print(f" using qcow2 {QCOW2URL}")

    QCOW2 = os.path.basename(QCOW2URL)
    print(f" select QCOW2 {QCOW2}")
    os.chdir(args.workdir)
    if not os.path.isfile(QCOW2):
        print(f" start to download {QCOW2URL}")
        do_exe_cmd(["wget", "-c", QCOW2URL], check=True)
    else:
        print(f" already exists {QCOW2}, reusing it.")
        do_exe_cmd(["qemu-nbd", "--disconnect", QCOW2])
        do_exe_cmd(["modprobe", "nbd", "max_part=9"])

    NBD = None
    for nbd in ["/dev/nbd" + str(i) for i in range(9)]:
        if do_exe_cmd(["qemu-nbd", "--connect", nbd, QCOW2]).returncode == 0:
            do_exe_cmd(["sync"])
            NBD = nbd
            break

    if not NBD:
        print("No available nbd found!")
        sys.exit(1)

    TMPMNT = "/tmp/qcow2-" + str(random.randint(0, 9999))
    os.makedirs(TMPMNT, exist_ok=True)
    do_exe_cmd(["mount", "-o", "rw", NBD + "p1", TMPMNT], check=True)
    do_exe_cmd(["ls", TMPMNT + "/boot/"])

    # copy linux vmlinuz
    if os.path.isdir(args.workdir + "/boot") and args.workdir + "/boot" != "/boot":
        shutil.copytree(args.workdir + "/boot/", TMPMNT + "/boot/")
        print(" copy vmlinuz done!")

    # copy linux modules
    if os.path.isdir(args.workdir + "/lib/modules") and args.workdir + "/lib" != "/lib":
        shutil.copytree(args.workdir + "/lib/modules/", TMPMNT + "/lib/modules/")
        print(f" copy modules(stripped) done! {TMPMNT}/lib/modules/")

    # copy linux headers
    if os.path.isdir(args.workdir + "/usr/src") and args.workdir + "/usr" != "/usr":
        shutil.copytree(args.workdir + "/usr/src/", TMPMNT + "/usr/src/")
        print(f" copy headers done! {TMPMNT}/usr/src")

    # set passwd
    # if TMPMNT != "/":
    #	NEWPASSWD='root:$y$j9T$LVUsOCwrorSF0vX0oHD1g1$64jSrSnxxzwDHPQ0j6/AT0OgpgeKI7zIuUdtBxzT6hA:19531:0:99999:7:::'
    #	with open(TMPMNT + "/etc/shadow") as f:
    #		lines = f.readlines()
    #	lines[0] = NEWPASSWD + "\n"
    #	with open(TMPMNT + "/etc/shadow", "w") as f:
    #		f.writelines(lines)
    #	print(" set root passwd : linux")

    # set hostname
    HOSTNAME = QCOW2.split(".")[0]
    with open(TMPMNT + "/etc/hostname", "w") as f:
        f.write(HOSTNAME + "\n")
    print(f" set hostname : {HOSTNAME}")

    # disable cloud init
    if os.path.isdir(TMPMNT + "/etc/cloud"):
        with open(TMPMNT + "/etc/cloud/cloud-init.disabled", "w") as f:
            f.write("")
        print(" disable cloud init")

    if os.path.isfile(TMPMNT + "/usr/bin/cloud-*"):
        os.remove(TMPMNT + "/usr/bin/cloud-*")

    with open(TMPMNT + "/etc/firstboot", "w") as f:
        f.write("")

    # set first boot script
    with open(TMPMNT + "/etc/rc.local", "w") as f:
        f.write("""#!/bin/bash

if [ -f /etc/firstboot ]; then
	rm -f /etc/firstboot
	cd /boot
	for k in $(ls vmlinuz-*); do
		KERNEL=${k//vmlinuz-/}
		update-initramfs -k ${KERNEL} -c
	done
	update-grub2
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
	ssh-keygen -A
	reboot -f
fi

exit 0

""")
    os.chmod(TMPMNT + "/etc/rc.local", 0o755)
    print(" set rc.local done!")

    print(" All setting done. clean...")
    do_exe_cmd(["umount", TMPMNT], check=True)
    do_exe_cmd(["sync"])
    do_exe_cmd(["qemu-nbd", "--disconnect", NBD], check=True)
    do_exe_cmd(["sync"])
    os.rmdir(TMPMNT)
    do_exe_cmd(["sync"])


def handle_qemu(args):
    if os.path.isfile("/.dockerenv"):
        print("must not run in docker!")
        sys.exit(1)
    if args.arch == "x86_64":
        QEMUAPP = "qemu-system-x86_64"
    elif args.arch == "arm64":
        QEMUAPP = "qemu-system-aarch64"
    else:
        print(f"Unsupported arch {args.arch}", file=sys.stderr)
        sys.exit(1)
    QEMUAPP = do_exe_cmd(["which", QEMUAPP], capture_output=True, text=True).stdout.strip()
    print(QEMUAPP)
    do_exe_cmd([QEMUAPP, "--version"], check=True)
    if do_exe_cmd([QEMUAPP, "--version"]).returncode != 0:
        print(f"you need install qemu-system-{args.arch} at first")
        print("Tips: run `kdev -i`")
        sys.exit(1)
    if do_exe_cmd(["virsh", "--version"]).returncode != 0:
        print("you need install libvirt-clients at first")
        print("Tips: run `kdev -i`")
        sys.exit(1)
    if args.arch == "x86_64":
        QCOW2URL = ROOTFS_AMD64_QCOW2[args.masterversion]
    elif args.arch == "arm64":
        QCOW2URL = ROOTFS_ARM64_QCOW2[args.masterversion]
    else:
        print(f"Unsupported arch {args.arch}", file=sys.stderr)
        sys.exit(1)

    if not QCOW2URL:
        print(" no qcow2 support current kernel version")
        sys.exit(1)
    else:
        print(f" using qcow2 {QCOW2URL}")

    QCOW2 = os.path.basename(QCOW2URL)
    os.chdir(args.workdir)
    QCOW2 = os.path.realpath(QCOW2)
    if not os.path.isfile(QCOW2):
        print(" no qcow2 found!")
        print("Tips: run `kdev -i`")
        sys.exit(1)
    else:
        print(f" found QCOW2 {QCOW2} in workdir, using it.")

    if not VMNAME:
        VMNAME = f"linux-{args.masterversion}-{args.arch}"

    print(f" try startup {VMNAME}")
    VMSTAT = do_exe_cmd(["virsh", "domstate", VMNAME], capture_output=True, text=True).stdout.strip()
    if VMSTAT:
        if VMSTAT == "running":
            print(f"{VMNAME} already running")
            return
        do_exe_cmd(["virsh", "start", VMNAME], check=True)
        return

    print(f" {VMNAME} does't exists! create new vm")
    if args.arch == "x86_64":
        VIRSHARCH = "x86_64"
    elif args.arch == "arm64":
        VIRSHARCH = "aarch64"
        VIRSHVCPU = "2"
        VIRSHRAM = "4096"
    else:
        print(f"Unsupported arch {args.arch}", file=sys.stderr)
        sys.exit(1)

    if not VIRSHVCPU:
        VIRSHVCPU = "8"

    if not VIRSHRAM:
        VIRSHRAM = "8192"

    do_exe_cmd(
        ["virt-install", "--name", VMNAME, "--arch", VIRSHARCH, "--ram", VIRSHRAM, "--os-type=linux", "--video=vga",
         "--vcpus", VIRSHVCPU, "--disk", f"path={QCOW2},format=qcow2,bus=scsi", "--network",
         "bridge=br0,virtualport_type=openvswitch", "--import", "--graphics", "spice,listen=0.0.0.0",
         "--noautoconsole"], check=True)

    print(f" start {VMNAME} success! enjoy it~~")


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

    # subcommand check
    parser_check = subparsers.add_parser('check', parents=[parent_parser])
    parser_check.add_argument("-i", "--aptinstall", action="store_true", help="install dependency packages")
    parser_check.set_defaults(func=handle_check)

    # subcommand kernel
    parser_kernel = subparsers.add_parser('kernel', parents=[parent_parser])
    parser_kernel.add_argument("--nodocker", action="store_true", help="build kernel without docker environment")
    parser_kernel.add_argument("-j", "--job", default=os.cpu_count(), help="setup compile job number")
    parser_kernel.add_argument("-c", "--clean", help="clean docker when exit"
                                                     "")
    parser_kernel.set_defaults(func=handle_kernel)

    # subcommand rootfs
    parser_rootfs = subparsers.add_parser('rootfs', parents=[parent_parser])
    parser_rootfs.add_argument('-r', '--release', action='store_true')
    parser_rootfs.set_defaults(func=handle_rootfs)

    # subcommand qemu
    parser_qemu = subparsers.add_parser('qemu', parents=[parent_parser])
    parser_qemu.set_defaults(func=handle_qemu)
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
