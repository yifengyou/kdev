# not supported

```text


EFI stub: Booting Linux Kernel...
EFI stub: Generating empty DTB
EFI stub: Exiting boot services and installing virtual address map...
[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.4.0-31-generic (buildd@bos01-arm64-003) (gcc version 5.3.1 20160413 (Ubuntu/Linaro 5.3.1-14ubuntu2.1) ) #50-Ubuntu SMP Wed Jul 13 00:06:30 UTC 2016 (Ubuntu 4.4.0-31.50-generic 4.4.13)
[    0.000000] Boot CPU: AArch64 Processor [481fd010]
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] earlycon: Early serial console at MMIO 0x9000000 (options '')
[    0.000000] bootconsole [uart0] enabled
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] EFI v2.70 by EDK II
[    0.000000] efi:  SMBIOS 3.0=0x13bed0000  ACPI 2.0=0x138430018 
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x0000000138430018 000024 (v02 BOCHS )
[    0.000000] ACPI: XSDT 0x000000013843FE98 000064 (v01 BOCHS  BXPC     00000001      01000013)
[    0.000000] ACPI: FACP 0x000000013843FA98 00010C (v05 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000138437518 001B6E (v02 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000013843A198 001368 (v03 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: PPTT 0x000000013843E998 000538 (v02 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: GTDT 0x000000013843FC18 000060 (v02 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: MCFG 0x000000013843FF98 00003C (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: SPCR 0x000000013843FD18 000050 (v02 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: DBG2 0x000000013843FD98 000057 (v00 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] ACPI: IORT 0x000000013843F018 000080 (v03 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.000000] No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem 0x0000000000000000-0x000000013fffffff]
[    0.000000] NUMA: Adding memblock [0x40000000 - 0x13fffffff] on node 0
[    0.000000] NUMA: Initmem setup node 0 [mem 0x40000000-0x13fffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x13fffa280-0x13fffbfff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000040000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000040000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000040000000-0x000000013fffffff]
[    0.000000] On node 0 totalpages: 1048576
[    0.000000]   DMA zone: 12288 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 786432 pages, LIFO batch:31
[    0.000000]   Normal zone: 4096 pages used for memmap
[    0.000000]   Normal zone: 262144 pages, LIFO batch:31
[    0.000000] psci: probing for conduit method from ACPI.
[    0.000000] psci: PSCIv1.1 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: Trusted OS migration not required
[    0.000000] PERCPU: Embedded 17 pages/cpu @ffff8000fb3c0000 s31128 r8192 d30312 u69632
[    0.000000] pcpu-alloc: s31128 r8192 d30312 u69632 alloc=17*4096
[    0.000000] pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
[    0.000000] pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 [0] 12 [0] 13 [0] 14 [0] 15 
[    0.000000] pcpu-alloc: [0] 16 [0] 17 [0] 18 [0] 19 [0] 20 [0] 21 [0] 22 [0] 23 
[    0.000000] pcpu-alloc: [0] 24 [0] 25 [0] 26 [0] 27 [0] 28 [0] 29 [0] 30 [0] 31 
[    0.000000] pcpu-alloc: [0] 32 [0] 33 [0] 34 [0] 35 [0] 36 [0] 37 [0] 38 [0] 39 
[    0.000000] pcpu-alloc: [0] 40 [0] 41 [0] 42 [0] 43 [0] 44 [0] 45 [0] 46 [0] 47 
[    0.000000] pcpu-alloc: [0] 48 [0] 49 [0] 50 [0] 51 [0] 52 [0] 53 [0] 54 [0] 55 
[    0.000000] pcpu-alloc: [0] 56 [0] 57 [0] 58 [0] 59 [0] 60 [0] 61 [0] 62 [0] 63 
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1032192
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: auto=true priority=critical url=http://192.168.122.1:26237/preseed.cfg autoinstall earlyprintk ignore_loglevel console=ttyAMA0,115200n8 earlycon=pl011,mmio,0x09000000 level=10  initrd=initrd
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 258048 bytes
[    0.000000] log_buf_len min size: 16384 bytes
[    0.000000] log_buf_len: 524288 bytes
[    0.000000] early log buf free: 11704(71%)
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] software IO TLB [mem 0xfbfff000-0xfffff000] (64MB) mapped at [ffff8000bbfff000-ffff8000bfffefff]
[    0.000000] Memory: 4027612K/4194304K available (8752K kernel code, 1022K rwdata, 3792K rodata, 760K init, 786K bss, 166692K reserved, 0K cma-reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vmalloc : 0xffff000000000000 - 0xffff7bffbfff0000   (126974 GB)
[    0.000000]     vmemmap : 0xffff7bffc0000000 - 0xffff7fffc0000000   (  4096 GB maximum)
[    0.000000]               0xffff7bffc0000000 - 0xffff7bffc4000000   (    64 MB actual)
[    0.000000]     fixed   : 0xffff7ffffa7fd000 - 0xffff7ffffac00000   (  4108 KB)
[    0.000000]     PCI I/O : 0xffff7ffffae00000 - 0xffff7ffffbe00000   (    16 MB)
[    0.000000]     modules : 0xffff7ffffc000000 - 0xffff800000000000   (    64 MB)
[    0.000000]     memory  : 0xffff800000000000 - 0xffff800100000000   (  4096 MB)
[    0.000000]       .init : 0xffff800000cc2000 - 0xffff800000d80000   (   760 KB)
[    0.000000]       .text : 0xffff800000080000 - 0xffff800000cc2000   ( 12552 KB)
[    0.000000]       .data : 0xffff800000d91000 - 0xffff800000e90a00   (  1023 KB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=128 to nr_cpu_ids=64.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=64
[    0.000000] NR_IRQS:64 nr_irqs:64 0
[    0.000000] Kernel panic - not syncing: No interrupt controller found.
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-31-generic #50-Ubuntu
[    0.000000] Hardware name: (null) (DT)
[    0.000000] Call trace:
[    0.000000] [<ffff80000008a780>] dump_backtrace+0x0/0x1b0
[    0.000000] [<ffff80000008a954>] show_stack+0x24/0x30
[    0.000000] [<ffff80000045fd3c>] dump_stack+0x98/0xbc
[    0.000000] [<ffff8000001cc1f0>] panic+0xf8/0x23c
[    0.000000] [<ffff800000cc5a28>] init_IRQ+0x24/0x2c
[    0.000000] [<ffff800000cc28b0>] start_kernel+0x2a0/0x414
[    0.000000] [<0000000040903000>] 0x40903000
[    0.000000] ---[ end Kernel panic - not syncing: No interrupt controller found.

```
