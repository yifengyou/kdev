#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
 Authors:
   yifengyou <842056007@qq.com>
"""

import datetime
import glob
import logging
import os
import random
import re
import shutil
import stat
import subprocess
import sys
import argparse
import time
import select

try:
    import pexpect
except ImportError:
    print("need pexpect package, you can run 'pip3 install pexpect' to install it.")
    exit(1)

from logging.handlers import RotatingFileHandler

CURRENT_VERSION = "0.2.0-20250517"

timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")
log = logging.getLogger("kdev")

KERNEL_BUILD_MAP = {
    "linux-2.0": {
        "docker": [
            "yifengyou/linux2.0:latest"
        ],
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img"
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com/releases/lucid/release-20150427/ubuntu-10.04-server-cloudimg-amd64-disk1.img",
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-3.0": {
        "docker": [
            "yifengyou/linux3.0:latest"
        ],
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images-archive.ubuntu.com/releases/precise/release-20170502/ubuntu-12.04-server-cloudimg-amd64-disk1.img",
                        "http://cloud-images.ubuntu.com/releases/trusty/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img",
                        "http://cloud-images.ubuntu.com/releases/trusty/release/ubuntu-14.04-server-cloudimg-amd64-uefi1.img",
                    ],
                    "debian": [
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com/releases/trusty/release/ubuntu-14.04-server-cloudimg-arm64-disk1.img",
                        "http://cloud-images.ubuntu.com/releases/trusty/release/ubuntu-14.04-server-cloudimg-arm64-uefi1.img",
                    ],
                    "debian": [],
                    "centos": [],
                    "fedora": [],
                }
            }
    },
    "linux-4.0": {
        "docker": [
            "yifengyou/linux4.0:latest"
        ],
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/buster/latest/debian-10-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-arm64.img",
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
            "yifengyou/linux5.0:latest"
        ],
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com//releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "http://cloud-images.ubuntu.com//releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.img",
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
            "yifengyou/linux6.0:latest"
        ],
        "image":
            {
                "x86_64": {
                    "ubuntu": [
                        "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img",
                    ],
                    "debian": [
                        "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2",
                    ],
                    "centos": [],
                    "fedora": [],
                },
                "arm64": {
                    "ubuntu": [
                        "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-arm64.img",
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


def check_python_version():
    current_python = sys.version_info[0]
    if current_python == 3:
        return
    else:
        raise Exception('Invalid python version requested: %d' % current_python)


def check_config(args):
    # 解析命令后解析配置文件，合并两者
    find_kdev_config = False
    for filename in os.listdir('.'):
        if filename.endswith(".kdev"):
            find_kdev_config = True
            log.debug("load config file %s" % filename)
            with open(filename, 'r', encoding='utf8') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    match = re.match(r'(\w+)\s*=\s*([\w/.-]+)', line)
                    if match:
                        key = match.group(1)
                        value = match.group(2)
                        # 如果命令行没有定义key，则使用配置中的KV
                        if not hasattr(args, key):
                            setattr(args, key, value)
                        # 如果命令行未打开选项，但配置中打开，则使用配置中的KV
                        if getattr(args, key) is None:
                            setattr(args, key, value)
    if not find_kdev_config:
        print("Error! no kdev config (ends with .kdev) found! ")
        exit(1)


def check_privilege():
    if os.getuid() == 0:
        return
    else:
        log.info("superuser root privileges are required to run")
        log.info(f"  sudo kdev {' '.join(sys.argv[1:])}")
        sys.exit(1)


def check_arch(args):
    log.info("-> Step check environment")
    if args.arch:
        if args.arch == "x86_64":
            log.info("Target arch = [ x86_64 ]")
        elif args.arch == "arm64" or args.arch == "aarch64":
            log.info(f"Target arch = [ {args.arch} ]")
            args.arch = "arm64"
        else:
            log.info(f"Unsupported arch {args.arch}", file=sys.stderr)
            sys.exit(1)
    else:
        args.arch = os.uname().machine
        log.info(f"Target arch = [ {args.arch} ] (auto-detect)")


def check_src_hugefile(args):
    # github不支持直接推送100M+文件，尽量不要大文件
    ret, _, _ = do_exe_cmd(["find", args.sourcedir, "-name", ".git", "-prune", "-type", "f", "-size", "+100M"],
                           capture_output=True, text=True)
    if ret == 0:
        log.warning("Warnning!find file large than 100MB")


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


def init_logger():
    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s'))
    log.addHandler(console_handler)
    logfile = os.path.join("kdev.log")
    file_handler = RotatingFileHandler(
        filename=logfile,
        encoding='UTF-8',
        maxBytes=(1024 * 1024 * 1024),
        backupCount=10
    )
    file_handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s'))
    log.addHandler(file_handler)
    log.setLevel(logging.INFO)


def do_umount(target_dir):
    do_exe_cmd("sync")
    time.sleep(2)
    # lazy 延迟卸载机制
    umount_cmd = f"umount -l {target_dir}"
    do_exe_cmd(umount_cmd, print_output=False, shell=False, enable_log=False)


def do_exe_cmd(cmd, enable_log=False, logfile="build-kernel.log", print_output=False, shell=False):
    stdout_output = ''
    stderr_output = ''
    if isinstance(cmd, str):
        cmd = cmd.split()
    elif isinstance(cmd, list):
        pass
    else:
        raise Exception("unsupported type when run do_exec_cmd", type(cmd))
    if enable_log:
        log_file = open(logfile, "w+")
    log.info("-> Exe cmd:" + " ".join(cmd))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=shell)
    while True:
        try:
            # 使用select模块，监控stdout和stderr的可读性，设置超时时间为0.1秒
            rlist, _, _ = select.select([p.stdout, p.stderr], [], [], 0.1)
        except KeyboardInterrupt:
            log.info("* cancel by user interrupt")
            sys.exit(1)
        # 遍历可读的文件对象
        for f in rlist:
            # 读取一行内容，解码为utf-8
            line = f.read1(1 * 1024 * 1024).decode('utf8').strip()
            # 如果有内容，判断是stdout还是stderr，并打印到屏幕，并刷新缓冲区
            if line:
                if f == p.stdout:
                    if print_output == True:
                        log.info(f"STDOUT {line.strip()}")
                    if enable_log:
                        log_file.write(line.strip())
                    stdout_output += line.strip()
                    sys.stdout.flush()
                elif f == p.stderr:
                    if print_output == True:
                        log.info(f"STDERR {line.strip()}")
                    if enable_log:
                        log_file.write(line.strip())
                    stderr_output += line.strip()
                    sys.stderr.flush()
        if p.poll() is not None:
            break

    # 关闭日志描述符
    if enable_log:
        log_file.close()

    return p.returncode, stdout_output, stderr_output


def do_clean_nbd():
    for entry in os.listdir("/sys/block/"):
        full_path = os.path.join("/sys/block/", entry)
        if os.path.isdir(full_path) and os.path.basename(full_path).startswith("nbd"):
            if os.path.exists(os.path.join(full_path, "pid")):
                nbd_name = os.path.basename(full_path)
                retcode, _, _ = do_exe_cmd(f"qemu-nbd -d /dev/{nbd_name}", print_output=True)
                if 0 != retcode:
                    log.info(f"umount {nbd_name} failed! retcode={retcode}")
                else:
                    log.info(f"umount {nbd_name} done!")


def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        elapsed = end - start
        log.info(f"-> {func.__name__} Done! Ret=[ {result} ] Runtime=[ {format(elapsed / 60, '.3f')} min ]")
        log.info(f"-> Repeat Cmdline: [{' '.join(sys.argv)}]")
        if result:
            exit(result)
        return result

    return wrapper


@timer
def handle_init(args):
    check_arch(args)
    deplist = "git  " \
              "wget  " \
              "vim " \
              "flex " \
              "bison " \
              "build-essential " \
              "tmux " \
              "qemu-system-x86 libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager " \
              "openvswitch-common openvswitch-dev openvswitch-switch " \
              "firmware-misc-nonfree " \
              "ipxe-qemu " \
              "libvirt-daemon-driver-qemu " \
              "qemu " \
              "qemu-efi " \
              "qemu-efi-aarch64 " \
              "qemu-efi-arm " \
              "qemu-system " \
              "qemu-system-arm " \
              "qemu-system-common " \
              "qemu-system-data " \
              "qemu-system-gui:amd64 " \
              "qemu-system-mips " \
              "qemu-system-misc " \
              "qemu-system-ppc " \
              "qemu-system-sparc " \
              "qemu-system-x86 " \
              "qemu-user " \
              "qemu-user-binfmt " \
              "qemu-utils " \
              "sysstat " \
              "python3-pip " \
              "curl " \
              "file " \
              "docker-ce"
    ret, _, stderr = do_exe_cmd(f"sudo apt-get install -y {deplist}", print_output=False)
    if ret != 0:
        log.error(f"install dependency failed! \n{stderr}")
        return 1
    log.info(f"install {deplist} success!")
    return 0


def handle_check(args):
    check_arch(args)
    if not args.workdir:
        args.workdir = os.getcwd()
    log.info(f"workdir : {args.workdir}")

    if args.sourcedir:
        if not os.path.isdir(args.sourcedir):
            log.info(f"dir {args.sourcedir} does't exists!")
            exit(1)
    else:
        args.sourcedir = os.getcwd()
        log.info(f"sourcedir is {args.sourcedir}")

    if os.path.isfile(os.path.join(args.sourcedir, "Makefile")) and \
            os.path.isfile(os.path.join(args.sourcedir, "Kbuild")):
        log.info(f"Check {args.sourcedir} ok! It's kernel source directory.")
    else:
        log.info(f"Check {args.sourcedir} failed! It's not a kernel source directory.")
        exit(1)

    os.chdir(args.sourcedir)
    ret, kernelversion, _ = do_exe_cmd("make kernelversion")
    if ret != 0:
        log.error(f"Unsupported {kernelversion}")
        exit(1)

    args.kernelversion = kernelversion.strip()
    log.info(f"kernel version : {args.kernelversion}")

    args.masterversion = args.kernelversion[0]
    if args.masterversion not in [str(i) for i in range(1, 7)]:
        log.error("unsupoorted masterversion", args.masterversion)
    log.info(f"master version : {args.masterversion}")

    return 0


@timer
def handle_build_kernel(args):
    handle_check(args)
    log.info("-> Step build kernel")
    os.chdir(args.workdir)

    if args.config:
        log.info(f" set kenrel config from cmdline {args.config}")
        kernel_config = args.config
    else:
        kernel_config = f"{args.arch}_defconfig"

    mrproper = ""
    if hasattr(args, 'mrproper') and ('1' == args.mrproper or 'True' == args.mrproper):
        mrproper = "make mrproper"

    # 生产编译脚本，因为不同环境对python版本有依赖要求，暂时不考虑规避，脚本万能
    body = """
cd ${WORKDIR}

""" + mrproper + """

if [ -f .config ]; then
    cp -a .config .config-bak
fi

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} """ + kernel_config + """
if [ $? -ne 0 ]; then
    echo "make  """ + kernel_config + """ failed!"
    exit 1
fi

if [ -f .config-bak ] ; then
    diff .config .config-bak
    if [ $? -eq 0 ];then
        cp -a .config-bak .config
    fi
fi

ls -alh ${WORKDIR}/.config
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j "${JOB}"
if [ $? -ne 0 ]; then
    echo "Build kernel binary failed!"
    exit 1
fi

echo " kernel install to ${OUTPUTDIR}/boot"
if [ ! -d "${OUTPUTDIR}/boot" ]; then
    mkdir -p ${OUTPUTDIR}/boot
fi
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install INSTALL_PATH=${OUTPUTDIR}/boot
if [ $? -ne 0 ]; then
    echo "make install to ${OUTPUTDIR}/boot failed!"
    exit 1
fi

echo " kernel modules install to ${OUTPUTDIR}"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOB} INSTALL_MOD_PATH=${OUTPUTDIR}/
if [ $? -ne 0 ]; then
    # try again
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 modules_install -j ${JOB} INSTALL_MOD_PATH=${OUTPUTDIR}/
    if [ $? -ne 0 ]; then
        echo "make modules_install to ${OUTPUTDIR} failed!"
        exit 1
    fi
fi

KERNELRELEASE=$( make -s --no-print-directory ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} kernelrelease 2>/dev/null )
KERNEL_DEVEL_DIR=${OUTPUTDIR}/usr/src/linux-headers-${KERNELRELEASE}
mkdir -p ${KERNEL_DEVEL_DIR}
echo " kernel headers install to ${KERNEL_DEVEL_DIR}"

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_install INSTALL_HDR_PATH=${OUTPUTDIR}/usr
if [ $? -ne 0 ]; then
    echo "make headers_install to ${OUTPUTDIR} failed!"
    exit 1
fi

# linux 6.6 will build failed!
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_check INSTALL_HDR_PATH=${OUTPUTDIR}/usr || :

"""

    isoimage_script = """
echo " build isoimage"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 isoimage -j ${JOB}
if [ $? -ne 0 ]; then
    # try again
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 isoimage -j ${JOB}
    if [ $? -ne 0 ]; then
        echo "make isoimage failed!"
        exit 1
    fi
fi
"""
    if hasattr(args, 'isoimage') and args.isoimage == True:
        body += isoimage_script

    body += """

# add linux-headers/kernel-devel files
cd ${WORKDIR}
find -type f \( -name "Makefile*" -o -name "Kconfig*" \) -exec cp --parents {} ${KERNEL_DEVEL_DIR}/ \;
rsync -a --exclude='*.o' --exclude='*.cmd' .config include arch Module.* modules.* scripts include tools kdev ${KERNEL_DEVEL_DIR}/
find ${KERNEL_DEVEL_DIR}/ -name "*.o" -exec rm -rf {} \;
find ${KERNEL_DEVEL_DIR}/ -name ".*.cmd" -exec rm -f {} \;

rm -f ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/source ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/build
ln -svf   /usr/src/linux-headers-${KERNELRELEASE}   ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/source
ls -dlh ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/source
ln -svf   /usr/src/linux-headers-${KERNELRELEASE}   ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/build
ls -dlh ${OUTPUTDIR}/lib/modules/${KERNELRELEASE}/build

"""

    if hasattr(args, 'nodocker') and ('True' == args.nodocker or '1' == args.nodocker):
        log.info("build kernel in host")

        args.cross_compile = ''
        if os.uname().machine != args.arch:
            if args.arch == "arm64":
                args.cross_compile = "aarch64-linux-gnu-"

        head = """#!/bin/bash

set -x

if [ -f /.dockerenv ]; then
    echo "should run in host, not in docker"
    exit 1
fi

WORKDIR=%s
OUTPUTDIR=/rootfs
ARCH=%s
CROSS_COMPILE=%s
JOB=%s

""" % (
            args.workdir,
            args.arch,
            args.cross_compile,
            args.job,

        )
        with open("hostbuild.sh", "w") as script:
            script.write(head + body)

        os.chmod("hostbuild.sh", 0o755)
        host_cmd = "/bin/bash hostbuild.sh"
        ret, output, error = do_exe_cmd(host_cmd,
                                        print_output=True,
                                        enable_log=True,
                                        logfile="build_kernel_in_host.log")
        if ret != 0:
            log.error("host build failed!")
            return 1
        return 0

    else:
        log.info("build kernel in docker")

        if not (hasattr(args, "docker_image") and (args.docker_image != '')):
            ok, image = check_docker_image(args)
            if not ok:
                log.error("not useable docker image found!")
                return 1
            log.info(f" using docker image : {image} ")
            args.docker_image = image
        log.info(f"using docker image {args.docker_image}")

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
OUTPUTDIR=/rootfs
ARCH=%s
CROSS_COMPILE=%s
JOB=%s

""" % (
            "/workdir",
            args.arch,
            args.cross_compile,
            args.job if hasattr(args, 'job') else os.cpu_count(),
        )
        with open("dockerbuild.sh", "w") as script:
            script.write(head + body)
        os.chmod("dockerbuild.sh", 0o755)

        # overlay fs mount
        overlay_build_dir = f"{args.workdir}/build"
        overlay_work_dir = f"{args.workdir}/overlay-work"
        overlay_merged_dir = f"{args.workdir}/overlay-merged"
        output_dir = f"{args.workdir}/rootfs"

        os.makedirs(overlay_build_dir, exist_ok=True)
        os.makedirs(overlay_work_dir, exist_ok=True)
        os.makedirs(overlay_merged_dir, exist_ok=True)
        os.makedirs(output_dir, exist_ok=True)

        overlayfs_mount_cmd = f"mount -t overlay overlay" \
                              f" -o lowerdir={args.sourcedir},upperdir={overlay_build_dir},workdir={overlay_work_dir}" \
                              f" {overlay_merged_dir}"
        ret, output, error = do_exe_cmd(overlayfs_mount_cmd,
                                        print_output=True,
                                        shell=False,
                                        enable_log=True,
                                        logfile="build_kernel_in_docker.log")
        if ret != 0:
            log.error(f"overlayfs mount failed! [{overlayfs_mount_cmd}] retcode={ret}")
            exit(1)
        log.info(f"overlay mount success {overlay_merged_dir}!!")

        if args.bash:
            docker_cmd = f"\n\ndocker run -it" \
                         f" -v {args.workdir}/dockerbuild.sh:/bin/kdev " \
                         f" --hostname kdev-linux{args.masterversion} " \
                         f" -v {args.workdir}/overlay-merged:/workdir " \
                         f" -v {output_dir}:/rootfs " \
                         f" -w /workdir " \
                         f"{args.docker_image}  " \
                         f"/bin/bash\n\n"
            log.info(f"-> Exe cmd:\n{docker_cmd}")
            os.system(docker_cmd)
            do_umount(overlay_merged_dir)
            return 0

        docker_cmd = f"docker run -t" \
                     f" --hostname kdev-linux{args.masterversion} " \
                     f" -v {args.workdir}/dockerbuild.sh:/bin/kdev " \
                     f" -v {args.workdir}/overlay-merged:/workdir " \
                     f" -v {output_dir}:/rootfs " \
                     f" -w /workdir   " \
                     f"{args.docker_image}  " \
                     f"/bin/kdev"

        ret, output, error = do_exe_cmd(docker_cmd,
                                        print_output=True,
                                        shell=False,
                                        enable_log=True,
                                        logfile="build_kernel_in_docker.log")
        if ret != 0:
            log.error(f"docker build failed! retcode={ret}")
            log.info("you can run 'kdev bash' to enter build environment!!")
            do_umount(overlay_merged_dir)
            return 1
        log.info("You can run 'kdev bash' to enter build environment!!")
        do_umount(overlay_merged_dir)
        return 0


@timer
def handle_rootfs(args):
    handle_check(args)

    qcow2_image_f = ''
    # try config qcow2
    if hasattr(args, 'qcow2_image') and '' != args.qcow2_image:
        log.info("using qcow2 from config")
        qcow2_image_f = args.qcow2_image
    else:
        log.info("using qcow2 from downloading")
        ok, image_url = check_qcow_image(args)
        if not ok:
            log.error(" no available image found!")
        log.info(f" using qcows url {image_url}")

        args.qcow2_url = image_url
        args.qcow2 = os.path.basename(image_url)
        log.info(f" qcow2 name : {args.qcow2}")
        os.chdir(args.workdir)

        if not os.path.isfile(args.qcow2):
            log.info(f" start to download {args.qcow2_url}")
            retcode, _, _ = do_exe_cmd(["wget", "-c", args.qcow2_url],
                                       print_output=True,
                                       enable_log=True,
                                       logfile="kdev-download.log"
                                       )
            if retcode != 0:
                log.error("Download qcow2 failed!")
        else:
            log.info(f" already exists {args.qcow2}, reusing it.")
            do_exe_cmd(["qemu-nbd", "--disconnect", args.qcow2], print_output=True)
            do_exe_cmd(["modprobe", "nbd", "max_part=19"], print_output=True)
        qcow2_image_f = args.qcow2

    qcow2_image_f = os.path.realpath(qcow2_image_f)
    if not os.path.exists(qcow2_image_f):
        log.error(f"{qcow2_image_f} not found!")
        exit(1)

    if hasattr(args, "vmname"):
        vmname = args.vmname
        retcode, _, _ = do_exe_cmd(f"virsh domstate {vmname}", print_output=False)
        if 0 == retcode:
            retcode, _, _ = do_exe_cmd(f"virsh destroy {vmname}", print_output=True)
            if 0 == retcode:
                log.info(f" destroy vm {vmname} ok")
            else:
                log.info(f" destroy vm {vmname} failed!")
        else:
            log.info(f"no vm {vmname} found! skip clean vm.")

    # 稍作延迟
    do_exe_cmd("sync")

    if not (hasattr(args, "skipimagecheck") and args.skipimagecheck is not None):
        retcode, stdout, stderr = do_exe_cmd(f"qemu-img check {qcow2_image_f}", print_output=False)
        if retcode != 0:
            log.error(f"check qcow2 failed!\n{stderr.strip()}")
            return 1

    # 如果参数或配置指定了nbd，则使用，否则挨个测试
    if hasattr(args, 'nbd') and args.nbd is not None:
        do_exe_cmd(f"qemu-nbd --disconnect {os.path.join('/dev/', args.nbd)}", print_output=True)
        log.debug(f"try umount nbd /dev/{args.nbd}")
        retcode, _, _ = do_exe_cmd(["qemu-nbd", "--connect", os.path.join("/dev/", args.nbd), qcow2_image_f],
                                   print_output=True)
        if retcode != 0:
            log.error("Connect nbd failed!")
    else:
        for nbd in ["nbd" + str(i) for i in range(9)]:
            retcode, output, error = do_exe_cmd(
                ["qemu-nbd", "--connect", "/dev/" + nbd,
                 qcow2_image_f],
                print_output=True)
            if retcode == 0:
                args.nbd = nbd
                break
        if not hasattr(args, 'nbd'):
            log.error("No available nbd found!")

    # 稍作延迟
    do_exe_cmd("sync")

    # 创建临时挂载点
    args.tmpdir = "/tmp/qcow2-" + str(random.randint(0, 9999))
    os.makedirs(args.tmpdir, exist_ok=True)

    # 找到根分区
    target_part = None
    for part in range(10):
        disk_size = f"/sys/devices/virtual/block/{args.nbd}/{args.nbd}p{part}/size"
        if os.path.exists(disk_size):
            try:
                # 读取设备文件获取扇区数[3,4](@ref)
                with open(disk_size, 'r') as f:
                    sectors = int(f.read().strip())
            except Exception as e:
                log.err(f"try get {args.nbd}p{part} size failed! {str(e)}")
                do_clean_nbd()
                exit(1)
            size_mb = sectors * 512 / (1024 ** 2)
            # 找到第一个大于2G的盘，一般UEFI的ESP分区都是1G以下，不是一般性
            if size_mb > 2048:
                target_part = f"{args.nbd}p{part}"
                log.info(f"find disk part /dev/{target_part} size: {size_mb}")
                break
    if not target_part:
        log.error(f"no suitable part for mount on {args.nbd}")
        exit(1)
    # 尝试挂载
    retcode, _, _ = do_exe_cmd(f"mount -o rw /dev/{target_part} {args.tmpdir}", print_output=True)
    if retcode != 0:
        log.error(f"Mount qcow2 /dev/{target_part} failed!")
        exit(1)
    # 稍作延迟
    do_exe_cmd("sync")

    # 拷贝boot目录，包含linux vmlinuz config maps
    copy_rootfsdir = os.path.join(args.workdir, "rootfs")
    qcow_rootfsdir = os.path.join(args.tmpdir)
    if os.path.isdir(copy_rootfsdir) and qcow_rootfsdir != "/":
        copy_cmd = ["/usr/bin/rsync", "-ah", "--update", "-K", f"{copy_rootfsdir}/", f"{qcow_rootfsdir}/"]
        log.info(" run cmd: %s" % ' '.join(copy_cmd))
        retcode, _, error = do_exe_cmd(copy_cmd)
        if retcode == 0:
            log.info(f" copy rootfs ok! {qcow_rootfsdir}")
        else:
            log.error(f" copy rootfs failed!! {qcow_rootfsdir} {error}")

    # 稍作延迟
    do_exe_cmd("sync")

    # 设置主机名
    args.hostname = 'kdev'
    qcow_hostname = os.path.join(args.tmpdir, "etc/hostname")
    with open(qcow_hostname, "w") as f:
        f.write(args.hostname.strip())
    log.info(f" set hostname : {args.hostname}")

    # 检查cloud-init变关闭
    qcow_cloudinitdir = os.path.join(args.tmpdir, "etc/cloud")
    if os.path.isdir(qcow_cloudinitdir):
        with open(os.path.join(qcow_cloudinitdir, "cloud-init.disabled"), "w") as f:
            f.write("")
    if os.path.isfile(os.path.join(args.tmpdir, "usr/bin/cloud-*")):
        log.debug("remove /usr/bin/cloud-*")
        os.remove(os.path.join(args.tmpdir, "usr/bin/cloud-*"))

    TMP_USRBIN = os.path.join(args.tmpdir, "usr/bin/")
    for item in os.listdir(TMP_USRBIN):
        if item.startswith("cloud-"):
            new_item = "bak-" + item
            os.rename(os.path.join(TMP_USRBIN, item), os.path.join(TMP_USRBIN, new_item))
            log.info(f"Renamed {item} to {new_item}")

    # 写入初始化脚本，开机第一次执行
    with open(os.path.join(args.tmpdir, "etc/firstboot"), "w") as f:
        f.write("")

    if hasattr(args, 'rclocal') and '' != args.rclocal:
        log.info("using custom rclocal from config")
        custom_rclocal = os.path.realpath(args.rclocal)
        if os.path.isfile(custom_rclocal):
            shutil.copy(custom_rclocal, os.path.join(args.tmpdir, "etc/rc.local"))
        else:
            log.error(f"{custom_rclocal} is not normal file!")
            exit(1)
    else:
        log.info("using default rclocal config")
        with open(os.path.join(args.tmpdir, "etc/rc.local"), "w") as f:
            f.write("""#!/bin/bash

if [ -f /etc/firstboot ]; then
    mv /etc/firstboot /etc/firstboot-bak
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

    # modify rootfs/etc/rc.local file mode
    os.chmod(os.path.join(args.tmpdir, "etc/rc.local"), 0o755)
    log.info(" set rc.local done!")

    log.info(" clean ...")
    retcode, _, _ = do_exe_cmd(f"umount -l {args.tmpdir}", print_output=True)
    if retcode != 0:
        log.error("Umount failed!")
    retcode, _, _ = do_exe_cmd(f"qemu-nbd --disconnect /dev/{args.nbd}", print_output=True)
    if retcode != 0:
        log.error("Disconnect nbd failed!")
    os.rmdir(args.tmpdir)
    return 0


@timer
def handle_run(args):
    handle_check(args)

    path = shutil.which("virt-install")
    # 判断路径是否为None，输出结果
    if path is None:
        log.error(f"virt-install is not found in the system.")
        exit(1)
    else:
        log.info(f"virt-install is found in the system at {path}.")

    # 检查是否有可用的QCOW2文件
    qcow2_image_f = ''
    # try config qcow2
    if hasattr(args, 'qcow2_image') and '' != args.qcow2_image:
        log.info("using qcow2 from config")
        qcow2_image_f = args.qcow2_image
    else:
        log.info("using qcow2 from downloading")
        ok, image_url = check_qcow_image(args)
        if not ok:
            log.error(" no available image found!")
        log.info(f" using qcows url {image_url}")

        args.qcow2_url = image_url
        args.qcow2 = os.path.basename(image_url)
        log.info(f" qcow2 name : {args.qcow2}")
        os.chdir(args.workdir)

        if not os.path.isfile(args.qcow2):
            log.error(f" not qcow2 found! run 'kdev rootfs'")
            exit(1)
        else:
            log.info(f" already exists {args.qcow2}, reusing it.")
            do_exe_cmd(["qemu-nbd", "--disconnect", args.qcow2], print_output=True)
            do_exe_cmd(["modprobe", "nbd", "max_part=19"], print_output=True)
        qcow2_image_f = args.qcow2

    qcow2_image_f = os.path.realpath(qcow2_image_f)
    if not os.path.exists(qcow2_image_f):
        log.error(f"{qcow2_image_f} not found!")
        exit(1)

    if hasattr(args, "vmname") or '' != args.vmname:
        vmname = args.vmname
    else:
        vmname = f"linux-{args.masterversion}-{args.arch}"

    log.info(f" try startup {vmname}")
    retcode, args.vmstat, _ = do_exe_cmd(f"virsh domstate {vmname}", print_output=False)
    if 0 == retcode:
        if args.vmstat.strip() == "running":
            log.info(f"{vmname} already running")
            os.system(f"virsh console --force {vmname}")
            log.info(f"you can run 'virsh console --force {vmname}' to attach vm again~")
            return
        ret, _, _ = do_exe_cmd(f"virsh start {vmname}", print_output=True)
        if 0 != ret:
            log.error(f"start vm {vmname} failed,check it.")
            return 1
        log.info(f"start vm {vmname} ok, enjoy it.")
        os.system(f"virsh console --force {vmname}")
        log.info(f"you can run 'virsh console --force {vmname}' to attach vm again~")
        return 0

    log.info(f" {vmname} does't exists! create new vm")

    if args.arch == "x86_64":
        args.vmarch = "x86_64"
        if not args.vmcpu:
            args.vmcpu = "8"
        if not args.vmram:
            args.vmram = "8192"
    elif args.arch == "arm64":
        args.vmarch = "aarch64"
        if not args.vmcpu:
            args.vmcpu = "8"
        if not args.vmram:
            args.vmram = "8192"
    else:
        log.error(f"unsupported arch {args.arch}")
        return 1

    enable_kvm = ""
    if os.path.exists("/dev/kvm"):
        enable_kvm = f"  --virt-type kvm "
    qemu_cmd = f"virt-install  " \
               f"  --name {vmname} " \
               f"  --arch {args.vmarch} " \
               f"  --ram {args.vmram} " \
               f"  --os-type=generic " \
               f"  --vcpus {args.vmcpu}  " \
               f"  --disk path={os.path.join(args.workdir, qcow2_image_f)},format=qcow2,bus=sata " \
               f"  --network default " \
               f"  {enable_kvm}" \
               f"  --graphics spice,listen=0.0.0.0 " \
               f"  --video vga " \
               f"  --boot hd " \
               f"  --noautoconsole " \
               f"  --import "

    retcode, _, stderr = do_exe_cmd(qemu_cmd, print_output=True)
    if 0 != retcode:
        log.info(f" start {vmname} failed! {stderr}")
        return 1
    log.info(f" start {vmname} success! enjoy it~~")

    os.system(f"virsh console --force {vmname}")
    log.info(f"you can run 'virsh console --force {vmname}' to attach vm again~")
    return 0


def handle_onekey(args):
    handle_build_kernel(args)
    handle_rootfs(args)
    handle_run(args)


@timer
def handle_clean(args):
    handle_check(args)
    # 清理虚拟机配置，保留qcow2
    if args.vm or args.all:

        if hasattr(args, "vmname"):
            vmname = args.vmname
        else:
            vmname = f"linux-{args.masterversion}-{args.arch}"
        retcode, _, _ = do_exe_cmd(f"virsh domstate {vmname}", print_output=False)
        if 0 == retcode:
            retcode, _, _ = do_exe_cmd(f"virsh destroy {vmname}", print_output=True)
            if 0 == retcode:
                log.info(f" destroy vm {vmname} ok")
            else:
                log.info(f" destroy vm {vmname} failed!")
            retcode, _, _ = do_exe_cmd(f"virsh undefine {vmname}", print_output=True)
            if 0 == retcode:
                log.info(f" undefine vm {vmname} ok")
            else:
                log.info(f" undefine vm {vmname} failed!")
        else:
            log.info(f"no vm {vmname} found! skip clean vm.")
    # 清理qcow2，保留虚机配置
    if args.qcow or args.all:
        os.chdir(args.workdir)
        for filename in os.listdir('.'):
            if filename.endswith(".qcow2"):
                log.debug(f" Find qcow2 {filename}")
                filepath = os.path.join(args.workdir, filename)
                os.remove(filepath)
                log.info(f"Deleted {filepath}")
    if args.docker or args.all:
        retcode, _, _ = do_exe_cmd(f"docker container prune -f", print_output=True)
        if 0 == retcode:
            log.info("clean docker container done!")
        else:
            log.info(f"clean docker container failed! retcode={retcode}")

    log.info("handle clean done!")


@timer
def handle_image(args):
    check_privilege()

    # 定义一个函数，判断一个路径是否是nbd开头的目录
    def is_nbd_dir(path):
        return os.path.isdir(path) and os.path.basename(path).startswith("nbd")

    def find_free_nbd():
        for entry in os.listdir("/sys/block/"):
            full_path = os.path.join("/sys/block/", entry)
            if is_nbd_dir(full_path):
                if not os.path.exists(os.path.join(full_path, "pid")):
                    return os.path.basename(full_path)
        return ''

    if args.mount:
        log.info("mount file :", args.mount)
        # 检查文件是否存在
        if os.path.isfile(args.mount):
            # 获取文件的绝对路径
            file = os.path.abspath(args.mount)

            nbd = find_free_nbd()
            if '' == nbd:
                log.error("no available /dev/nbd found!")
            log.info(f"try mount {file} to /dev/{nbd}")
            ok, _, _ = do_exe_cmd(f"qemu-nbd -c /dev/{nbd} {file}", print_output=True)
            if 0 != ok:
                log.error(f"qemu-nbd bind {file} failed! retcode={ok}")
            else:
                log.info(f"qemu-nbd bind {file} done!")
            mntdir = file + '-mnt'
            os.makedirs(mntdir, exist_ok=True)
            time.sleep(3)
            target_part = None
            for part in range(10):
                disk_size = f"/sys/devices/virtual/block/{nbd}/{nbd}p{part}/size"
                if os.path.exists(disk_size):
                    try:
                        # 读取设备文件获取扇区数[3,4](@ref)
                        with open(disk_size, 'r') as f:
                            sectors = int(f.read().strip())
                    except Exception as e:
                        log.err(f"try get {nbd}p{part} size failed! {str(e)}")
                        do_clean_nbd()
                        exit(1)
                    size_mb = sectors * 512 / (1024 ** 2)
                    # 找到第一个大于2G的盘，一般UEFI的ESP分区都是1G以下，不是一般性
                    if size_mb > 2048:
                        target_part = f"{nbd}p{part}"
                        log.info(f"find disk part target_part size: {size_mb}")
                        break
            if not target_part:
                log.error(f"no suitable part for mount on {nbd}")
                exit(1)
            ok, _, _ = do_exe_cmd(f"mount /dev/{target_part} {mntdir}", print_output=True)
            if 0 != ok:
                log.error(f"mount {target_part} {file} failed! retcode={ok}")
            else:
                log.info(f"mount {args.mount} to {mntdir} done!")
        else:
            # 打印错误信息
            log.info(f"File {args.umount} does not exist")
    elif args.umount:
        log.info("umount file :", args.umount)
        # 检查文件是否存在
        if os.path.isfile(args.umount):
            # 获取文件的绝对路径
            file = os.path.abspath(args.umount)
            # 获取挂载目录的绝对路径
            mnt_dir = file + "-mnt"
            if os.path.isdir(mnt_dir):
                retcode, _, _ = do_exe_cmd(f"umount {mnt_dir}")
                time.sleep(1)
                log.info(f"try umount {file} ret={retcode}")
                if len(os.listdir(mnt_dir)) != 0:
                    log.error(f"{mnt_dir} is not empty! umount failed! keep mount dir empty!")
                log.info(f"{mnt_dir} is already empty!")
            # disconnect nbd
            do_clean_nbd()
        else:
            # 打印错误信息
            log.info(f"File {args.umount} does not exist")


def do_handle_qemu_x86_64(args):
    # check bzImage
    bzImage_path = f"build/arch/{args.arch}/boot/bzImage"
    if not os.path.exists(bzImage_path):
        log.error(f"bzImage not found in [{bzImage_path}]")
        log.error(f"Tips: you shoud run 'kdev build' to build bzImage at first.")
        exit(1)
    log.info(f"-> using bzImage [{bzImage_path}]")

    # check initrd
    if hasattr(args, "initrd") and args.initrd != '':
        initrd_path = args.initrd
    else:
        initrd_path = "init.cpio"
    if not os.path.exists(initrd_path):
        log.error(f"init app not found in [{initrd_path}]")
        log.error(f"Tips: you shoud run 'kdev shell' enter build env to build it at first.")
        exit(1)
    log.info(f"-> using initrd [{initrd_path}]")

    # check kernel parameters
    kernel_parameter = ""
    if hasattr(args, "allparam") and args.allparam != '':
        kernel_parameter = str(args.allparam)
    if hasattr(args, "append") and args.append != '':
        kernel_parameter += " %s " % str(args.append)
    log.info(f"-> kernel parameter [{kernel_parameter}]")

    # check kvm support
    is_enable_kvm = "-enable-kvm"
    if not os.path.exists("/dev/kvm"):
        is_enable_kvm = ""
    gdb_tcp_port = "1234"
    if hasattr(args, "gdbport") and args.gdbport != '':
        gdb_tcp_port = str(args.gdbport)

    # generate qemu script
    qemu_script_path = os.path.join(args.workdir, "qemu.sh")
    qemu_cmd = rf"""#!/bin/bash
    qemu-system-x86_64 \
        -m 4096M \
        -smp 4,sockets=4,cores=1,threads=1 \
        -object memory-backend-ram,id=mem0,size=1G \
        -object memory-backend-ram,id=mem1,size=1G \
        -object memory-backend-ram,id=mem2,size=1G \
        -object memory-backend-ram,id=mem3,size=1G \
        -numa node,nodeid=0,memdev=mem0,cpus=0 \
        -numa node,nodeid=1,memdev=mem1,cpus=1 \
        -numa node,nodeid=2,memdev=mem2,cpus=2 \
        -numa node,nodeid=3,memdev=mem3,cpus=3 \
        -smp 4 {is_enable_kvm}  \
        -net nic \
        -kernel {bzImage_path} \
        -initrd {initrd_path} \
        -gdb tcp::{args.gdbport} -S \
        -append "{kernel_parameter}" \
        -nographic

        """
    with open(qemu_script_path, 'w') as qemu_script:
        qemu_script.write(qemu_cmd)
    os.chmod(qemu_script_path,
             stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR |  # 用户权限
             stat.S_IRGRP | stat.S_IWGRP |  # 组权限
             stat.S_IROTH)  # 其他用户权限
    log.info("-> generate qemu script:\n" + f"{qemu_cmd}")

    log.info(f"-> run qemu script [{qemu_script_path}]")
    log.info(f"""
    --------------------------------------------------------------------------------------
    TIPS 1. GDB attach
        cd  /linux/linux-{args.masterversion}.git
        gdb /linux/linux-{args.masterversion}.git-build-{args.arch}/build/vmlinux
            # target remote :1234
            # b vfs_write
            # c
    TIPS 2. Exit qemu
        You can press hot key 'CTRL + a + x' to exit qemu environtment
    --------------------------------------------------------------------------------------
    Enter debug mode! Waiting gdb cmd ...
        """)

    try:
        child = pexpect.spawn(f'{qemu_script_path}')
        child.interact()
        log.info("Qemu exited!")
    except pexpect.ExceptionPexpect as e:
        log.error(f"Qemu error: {e}")
        return 1
    return 0


def do_handle_qemu_arm64(args):
    # check bzImage
    bzImage_path = f"build/arch/{args.arch}/boot/Image"
    if not os.path.exists(bzImage_path):
        log.error(f"Image not found in [{bzImage_path}]")
        log.error(f"Tips: you shoud run 'kdev build' to build Image at first.")
        exit(1)
    log.info(f"-> using Image [{bzImage_path}]")

    # check initrd
    if hasattr(args, "initrd") and args.initrd != '':
        initrd_path = args.initrd
    else:
        initrd_path = "init.cpio"
    if not os.path.exists(initrd_path):
        log.error(f"init app not found in [{initrd_path}]")
        log.error(f"Tips: you shoud run 'kdev shell' enter build env to build it at first.")
        exit(1)
    log.info(f"-> using initrd [{initrd_path}]")

    # check kernel parameters
    kernel_parameter = ""
    if hasattr(args, "allparam") and args.allparam != '':
        kernel_parameter = str(args.allparam)
    if hasattr(args, "append") and args.append != '':
        kernel_parameter += " %s " % str(args.append)
    log.info(f"-> kernel parameter [{kernel_parameter}]")

    # check kvm support
    is_enable_kvm = "-enable-kvm"
    if not os.path.exists("/dev/kvm"):
        is_enable_kvm = ""
    gdb_tcp_port = "1234"
    if hasattr(args, "gdbport") and args.gdbport != '':
        gdb_tcp_port = str(args.gdbport)

    # generate qemu script
    qemu_script_path = os.path.join(args.workdir, "qemu.sh")
    qemu_cmd = rf"""#!/bin/bash
    qemu-system-aarch64 \
        -machine virt-5.2,accel=kvm \
        -cpu host \
        -m 4096M \
        -smp 4,sockets=4,cores=1,threads=1 \
        -object memory-backend-ram,id=mem0,size=1G \
        -object memory-backend-ram,id=mem1,size=1G \
        -object memory-backend-ram,id=mem2,size=1G \
        -object memory-backend-ram,id=mem3,size=1G \
        -numa node,nodeid=0,memdev=mem0,cpus=0 \
        -numa node,nodeid=1,memdev=mem1,cpus=1 \
        -numa node,nodeid=2,memdev=mem2,cpus=2 \
        -numa node,nodeid=3,memdev=mem3,cpus=3 \
        -smp 4 {is_enable_kvm}  \
        -net nic \
        -kernel {bzImage_path} \
        -initrd {initrd_path} \
        -gdb tcp::{args.gdbport} -S \
        -append "{kernel_parameter}" \
        -nographic

        """
    with open(qemu_script_path, 'w') as qemu_script:
        qemu_script.write(qemu_cmd)
    os.chmod(qemu_script_path,
             stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR |  # 用户权限
             stat.S_IRGRP | stat.S_IWGRP |  # 组权限
             stat.S_IROTH)  # 其他用户权限
    log.info("-> generate qemu script:\n" + f"{qemu_cmd}")

    log.info(f"-> run qemu script [{qemu_script_path}]")
    log.info(f"""
    --------------------------------------------------------------------------------------
    TIPS 1. GDB attach
        cd  /linux/linux-{args.masterversion}.git
        gdb /linux/linux-{args.masterversion}.git-build-{args.arch}/build/vmlinux
            # target remote :1234
            # b vfs_write
            # c
    TIPS 2. Exit qemu
        You can press hot key 'CTRL + a + x' to exit qemu environtment
    --------------------------------------------------------------------------------------
    Enter debug mode! Waiting gdb cmd ...
        """)

    try:
        child = pexpect.spawn(f'{qemu_script_path}')
        child.interact()
        log.info("Qemu exited!")
    except pexpect.ExceptionPexpect as e:
        log.error(f"Qemu error: {e}")
        return 1
    return 0


@timer
def handle_qemu(args):
    """
    执行 qmeu 调试模式，此模式不进行overlayfs挂载
    :param args:
    :return:
    """
    handle_check(args)
    os.chdir(args.workdir)
    log.info(f"-> current workdir {args.workdir}")

    if args.arch == 'x86_64':
        do_handle_qemu_x86_64(args)
    elif args.arch == 'arm64':
        do_handle_qemu_arm64(args)
    else:
        log.error("arch {args.arch} not supported now!")
        exit(1)


@timer
def handle_qcow(args):
    """
    :param args:
    :return:
    """
    handle_check(args)


def main():
    global CURRENT_VERSION
    check_python_version()

    # 顶层解析
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-v", "--version", action="store_true",
                        help="show program's version number and exit")
    parser.add_argument("-h", "--help", action="store_true",
                        help="show this help message and exit")
    subparsers = parser.add_subparsers()

    # 定义base命令用于集成
    parent_parser = argparse.ArgumentParser(add_help=False, description="kdev - a tool for kernel development")
    parent_parser.add_argument("-V", "--verbose", default=None, action="store_true", help="show verbose output")
    parent_parser.add_argument("-s", "--sourcedir", default=None, help="set kernel source dir")
    parent_parser.add_argument("-a", "--arch", default=None, help="set arch, default is x86_64")
    parent_parser.add_argument("-w", "--workdir", default=None, help="setup workdir")
    parent_parser.add_argument('--debug', default=None, action="store_true", help="enable debug")

    # 添加子命令 init
    parser_init = subparsers.add_parser('init', parents=[parent_parser], help="install dependency")
    parser_init.set_defaults(func=handle_init)

    # 添加子命令 check
    parser_check = subparsers.add_parser('check', parents=[parent_parser], help="check kdev config")
    parser_check.set_defaults(func=handle_check)

    # 添加子命令 bash
    parser_bash = subparsers.add_parser('bash', aliases=['shell', 'terminal'], parents=[parent_parser],
                                        help="enter build environment")
    parser_bash.add_argument("--config", help="setup kernel build config")
    parser_bash.add_argument("--bash", dest="bash", default=True, action="store_true",
                             help="break before build(just for docker build)")
    parser_bash.add_argument("--docker_image", dest="docker_image", help="specific docker image")
    parser_bash.set_defaults(func=handle_build_kernel)

    # 添加子命令 kernel
    parser_kernel = subparsers.add_parser('kernel', aliases=['build', 'compile'], parents=[parent_parser],
                                          help="build kernel")
    parser_kernel.add_argument("--nodocker", "--host", dest="nodocker", default=None, action="store_true",
                               help="build kernel without docker environment")
    parser_kernel.add_argument("-j", "--job", default=os.cpu_count(), help="setup compile job number")
    parser_kernel.add_argument("-c", "--clean", help="clean docker when exit")
    parser_kernel.add_argument("--config", help="setup kernel build config")
    parser_kernel.add_argument("--bash", dest="bash", default=None, action="store_true",
                               help="break before build(just for docker build)")
    parser_kernel.add_argument("--mrproper", dest="mrproper", default=None, action="store_true",
                               help="make mrproper before build")
    parser_kernel.add_argument("--isoimage", dest="isoimage", default=False, action="store_true",
                               help="make isoimage")
    parser_kernel.add_argument("--docker_image", dest="docker_image", help="specific docker image")
    parser_kernel.set_defaults(func=handle_build_kernel)

    # 添加子命令 rootfs
    parser_rootfs = subparsers.add_parser('rootfs', aliases=['vm', 'qcow2'], parents=[parent_parser],
                                          help="build rootfs")
    parser_rootfs.add_argument('-r', '--release', default=None, action="store_true")
    parser_rootfs.add_argument('-q', '--qcow2', dest="qcow2_image", default=None)
    parser_rootfs.set_defaults(func=handle_rootfs)

    # 添加子命令 run
    parser_run = subparsers.add_parser('run', aliases=['startup', 'start'], parents=[parent_parser],
                                       help="run kernel in qemu")
    parser_run.add_argument('-n', '--name', help="setup vm name")
    parser_run.add_argument('--vmcpu', help="setup vm vcpu number")
    parser_run.add_argument('--vmram', help="setup vm ram")
    parser_run.set_defaults(func=handle_run)

    # 添加子命令 onekey
    parser_onekey = subparsers.add_parser('onekey', aliases=['go', 'test'], parents=[parent_parser],
                                          help="build kernel and startup")
    parser_onekey.add_argument("--nodocker", "--host", dest="nodocker", default=None, action="store_true",
                               help="build kernel without docker environment")
    parser_onekey.add_argument("-j", "--job", default=os.cpu_count(), help="setup compile job number")
    parser_onekey.add_argument("-c", "--clean", help="clean docker when exit")
    parser_onekey.add_argument("--config", help="setup kernel build config")
    parser_onekey.add_argument("--bash", dest="bash", default=None, action="store_true",
                               help="break before build(just for docker build)")
    parser_onekey.add_argument("--mrproper", dest="mrproper", default=None, action="store_true",
                               help="make mrproper before build")
    parser_onekey.add_argument('-r', '--release', default=None, action="store_true")
    parser_onekey.add_argument('-q', '--qcow2', dest="qcow2_image", default=None)
    parser_onekey.add_argument('-n', '--name', help="setup vm name")
    parser_onekey.add_argument('--vmcpu', help="setup vm vcpu number")
    parser_onekey.add_argument('--vmram', help="setup vm ram")
    parser_onekey.set_defaults(func=handle_onekey)

    # 添加子命令 clean
    parser_clean = subparsers.add_parser('clean', parents=[parent_parser], help="clean buile environment")
    parser_clean.add_argument('--vm', default=None, action="store_true", help="clean vm (destroy/undefine)")
    parser_clean.add_argument('--qcow', default=None, action="store_true", help="delete qcow")
    parser_clean.add_argument('--docker', default=None, action="store_true", help="clean docker")
    parser_clean.add_argument('--all', default=None, action="store_true", help="clean all")
    parser_clean.set_defaults(func=handle_clean)

    # 添加子命令 image
    parser_image = subparsers.add_parser('image', help="tackle image")
    # 添加一个互斥组，用于指定-u或-m参数，但不能同时指定
    parser_image_group = parser_image.add_mutually_exclusive_group(required=True)
    parser_image_group.add_argument('-m', '--mount', metavar='QCOW2_FILE_PATH', help="mount qcow2")
    parser_image_group.add_argument('-u', '--umount', metavar='QCOW2_FILE_PATH', help="umount qcow2")
    parser_image_group.set_defaults(func=handle_image)

    # 添加子命令 qemu
    parser_qemu = subparsers.add_parser('qemu', parents=[parent_parser], help="run kernel with qemu directly")
    parser_qemu.add_argument("-j", "--job", default=os.cpu_count(), help="setup compile job number")
    parser_qemu.add_argument("--initrd", dest="initrd", help="specific initrd path")
    parser_qemu.add_argument("--append", dest="append", help="append kernel boot parameters")
    parser_qemu.add_argument("--gdbport", dest="gdbport", help="specific gdb tcp port")
    parser_qemu.add_argument("--allparam", dest="allparam", default='nokaslr console=ttyS0',
                             help="append kernel boot parameters")
    parser_qemu.set_defaults(func=handle_qemu)

    # 添加子命令 qcow
    parser_qcow = subparsers.add_parser('qcow', parents=[parent_parser], help="run kernel with qcow directly")
    parser_qcow.set_defaults(func=handle_qcow)

    # 开始解析命令
    args = parser.parse_args()

    # 检查配置文件
    check_config(args)
    # 初始化日志组件
    init_logger()

    # 参数解析后开始具备debug output能力
    if hasattr(args, "debug") and (args.debug == 'True' or args.debug == '1'):
        log.setLevel(logging.DEBUG)
        log.debug("Enable debug output")
    log.debug("Parser and config:")
    for key, value in vars(args).items():
        log.debug("  %s = %s" % (key, value))

    if args.version:
        log.info("kdev %s" % CURRENT_VERSION)
        sys.exit(0)
    elif args.help or len(sys.argv) < 2:
        parser.print_help()
        sys.exit(0)
    else:
        args.func(args)


if __name__ == "__main__":
    main()
