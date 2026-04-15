# not supported

```text
+ sync
+ '[' '!' -f debian-8.11.0-arm64-DVD-1.iso ']'
+ '[' '!' -f debian-8.11.0-arm64-DVD-1.iso ']'
+ '[' '!' -f debian-8.11.0-arm64-DVD-1.iso ']'
+ '[' '!' -f debian-8.11.0-arm64-DVD-1.iso ']'
+ ls -alh debian-8.11.0-arm64-DVD-1.iso
-rw-r--r-- 1 root root 3.7G  4月 15 11:06 debian-8.11.0-arm64-DVD-1.iso
+ echo 'kdev: debian-8.11.0-arm64-DVD-1.iso ready!'
kdev: debian-8.11.0-arm64-DVD-1.iso ready!
+ echo 'kdev: http server ready!'
kdev: http server ready!
+ sleep 3
++ pwd
+ python3 -m http.server 49147 --directory /kdev/kdev.git/iso/debian-8.11.0-arm64-DVD-1.iso
Serving HTTP on 0.0.0.0 port 49147 (http://0.0.0.0:49147/) ...
+ trap cleanup EXIT
+ mkdir -p mnt
+ mount debian-8.11.0-arm64-DVD-1.iso mnt
mount: /kdev/kdev.git/iso/debian-8.11.0-arm64-DVD-1.iso/mnt: WARNING: source write-protected, mounted read-only.
+ '[' 0 -ne 0 ']'
+ ls -alh mnt/install.a64
total 12M
dr-xr-xr-x 1 root root 2.0K  6月 23  2018 .
dr-xr-xr-x 1 root root 4.0K  6月 23  2018 ..
-r--r--r-- 1 root root 4.4M  6月 23  2018 initrd.gz
-r--r--r-- 1 root root 7.0M  6月 23  2018 vmlinuz
+ '[' 0 -ne 0 ']'
+ '[' '!' -f mnt/install.a64/vmlinuz ']'
+ '[' '!' -f mnt/install.a64/initrd.gz ']'
+ ls -alh /dev/kvm
crw-rw---- 1 root 36 10, 232  4月 15 12:33 /dev/kvm
+ qemu-system-aarch64 -name debian-8.11.0-arm64-DVD-1 -machine virt,gic-version=max -cpu cortex-a57 -smp 64 -semihosting -m 4096 -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash -drive file=rootfs.qcow2,format=qcow2 -drive file=debian-8.11.0-arm64-DVD-1.iso,format=raw,if=none,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom -boot order=dc -kernel mnt/install.a64/vmlinuz -initrd mnt/install.a64/initrd.gz -append 'auto=true priority=critical preseed/url=http://10.0.2.1:49147/preseed.cfg earlyprintk console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 ' -net user,host=10.0.2.1 -net nic,model=e1000 -display none -serial mon:stdio -nographic


EFI stub: Booting Linux Kernel...
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.16.0-6-arm64 (debian-kernel@lists.debian.org) (gcc version 4.8.4 (Debian/Linaro 4.8.4-1) ) #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08)
[    0.000000] CPU: AArch64 Processor [411fd070] revision 0
[    0.000000] Early serial console at MMIO 0x9000000 (options '')
[    0.000000] bootconsole [uart0] enabled
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] EFI v2.70 by EDK II
[    0.000000] efi:  ACPI 2.0=0x138430018 
[    0.000000] Failed to find device node for boot cpu
[    0.000000] DT missing boot CPU MPIDR, not enabling secondaries
[    0.000000] PERCPU: Embedded 12 pages/cpu @ffffffc0ff6c1000 s19264 r8192 d21696 u49152
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1034240
[    0.000000] Kernel command line: auto=true priority=critical preseed/url=http://10.0.2.1:49147/preseed.cfg earlyprintk console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10  initrd=initrd
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 4071972K/4194304K available (4446K kernel code, 580K rwdata, 1704K rodata, 390K init, 501K bss, 122332K reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vmalloc : 0xffffff8000000000 - 0xffffffbbffff0000   (245759 MB)
[    0.000000]     vmemmap : 0xffffffbc00e00000 - 0xffffffbc04600000   (    56 MB)
[    0.000000]     modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)
[    0.000000]     memory  : 0xffffffc000000000 - 0xffffffc100000000   (  4096 MB)
[    0.000000]       .init : 0xffffffc000683000 - 0xffffffc0006e4b40   (   391 kB)
[    0.000000]       .text : 0xffffffc000080000 - 0xffffffc000682be4   (  6155 kB)
[    0.000000]       .data : 0xffffffc0006e5000 - 0xffffffc0007762a8   (   581 kB)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=1.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
[    0.000000] NR_IRQS:64 nr_irqs:64 0
[    0.000000] Kernel panic - not syncing: No interrupt controller found.
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.16.0-6-arm64 #1 Debian 3.16.56-1+deb8u1
[    0.000000] Call trace:
[    0.000000] [<ffffffc000088cc8>] dump_backtrace+0x0/0x170
[    0.000000] [<ffffffc000088e5c>] show_stack+0x24/0x2c
[    0.000000] [<ffffffc0004caf4c>] dump_stack+0x88/0xac
[    0.000000] [<ffffffc0004c7ec8>] panic+0xec/0x244
[    0.000000] [<ffffffc000685164>] init_IRQ+0x24/0x2c
[    0.000000] [<ffffffc000683810>] start_kernel+0x238/0x3b8
[    0.000000] ---[ end Kernel panic - not syncing: No interrupt controller found.
./build-vm.sh: line 157: 36464 Killed                  qemu-system-aarch64 -name "${ISONAME%.*}" -machine virt,gic-version=max -cpu cortex-a57 -smp ${JOBS} -semihosting -m 4096 -drive file=/usr/share/AAVMF/AAVMF_CODE.fd,format=raw,if=pflash -drive file=rootfs.qcow2,format=qcow2 -drive file="${ISONAME}",format=raw,if=none,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom -boot order=dc -kernel mnt/install.a64/vmlinuz -initrd mnt/install.a64/initrd.gz -append "auto=true priority=critical preseed/url=http://10.0.2.1:${FILE_SERVER_PORT}/preseed.cfg earlyprintk console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10 " -net user,host=10.0.2.1 -net nic,model=e1000 -display none -serial mon:stdio -nographic
+ sync
+ ls -alh rootfs.qcow2
-rw-r--r-- 1 root root 200K  4月 15 12:33 rootfs.qcow2
```
