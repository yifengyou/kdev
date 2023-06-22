SOURCEDIR=/kernel/debian-linux-source-5.10/linux-5.10.179
MNTDIR=/mnt
NBD=nbd9

.PHONY: default check kernel mount umount

default:
	@echo "check             check environment"
	@echo "kernel            build kernel"
	@echo "rootfs            build rootfs"

check:
	kdev -c

kernel:
	kdev -k -s $(SOURCEDIR)

mount:
	qemu-nbd debian-11-nocloud-amd64.qcow2  --connect /dev/${NBD}
	@sync
	@mount /dev/${NBD}p1 $(MNTDIR)
	@echo "mount qcow2 rootfs to $(MNTDIR)"

umount:
	umount $(MNTDIR)
	qemu-nbd --disconnect /dev/${NBD}

