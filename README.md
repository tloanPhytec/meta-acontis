This Yocto Meta Layer serves to configure the phyCORE-AM68Ax Development Kit's MCU_Ethernet interface with an optimized atemsys kernel module that grants direct access to hardware and improves the performance of the EtherCAT Master Stack Software, EC-Master from Acontis. 

This Meta Layer was tested in combination with the following software components:

* BSP-Yocto-Ampliphy-AM68x-PD24.1.0 (Kirkstone)
* EC-Master-V3.3-Linux-ARM_64Bit-Eval

  * Due to licensing, this must be aquired from Acontis directly and then added to your root filesystem: https://www.acontis.com/en/ethercat-master.html

## BSP Integration

In order to evaluate this Meta Layer on your phyCORE-AM68Ax Development Kit, you must have first built the default BSP per the following development guide:

https://phytec.github.io/doc-bsp-yocto/bsp/am6x/am68x/pd24.1.0.html#building-the-bsp

Navigate to your BSP's sources directory:

```sh
cd $BUILDDIR/../sources
```

Clone this repo recursively so that the submodules are cloned as well:

```sh
git clone --recursive https://github.com/tloanPhytec/meta-acontis.git -b kirkstone-am68a
```

Enable the layer in your build:

```sh
cd $BUILDDIR
bitbake-layers add-layer ../sources/meta-acontis
```

Rebuild your target's image with bitbake:

```sh
MACHINE=phyboard-izar-am68x-2 DISTRO=ampliphy bitbake phytec-headless-image
```

Flash the resulting image to an SD Card and then expand the root filesystem:

```sh
# identify your SD Card
mount

umount /dev/sdX*
sudo bmaptool copy phytec-headless-image-phyboard-izar-am68x-2.wic.xz /dev/sdX
```

Once the SD Card is flashed, expand the SD Card's root filesystem:

```sh
sudo parted /dev/sdX resizepart 2 100%
sudo e2fsck -f /dev/sdX2
sudo resize2fs /dev/sdX2
```

Mount the root filesystem. The easiest way to do this is to just click the root partition of the connected SD Card in your system tray:

<img width="699" height="470" alt="systemtray" src="https://github.com/user-attachments/assets/4c7bb3d5-cddc-4395-b135-be4482972397" />

Copy the unpacked EC-Master-V3.3-Linux-ARM_64Bit-Eval tarball to your root filesystem:

```sh
sudo mkdir /media/user/root/root/EC-Master-V3.3-Linux-ARM_64Bit-Eval
sudo tar -xf EC-Master-V3.3-Linux-ARM_64Bit-Eval.tar.gz -C /media/user/root/root/EC-Master-V3.3-Linux-ARM_64Bit-Eval && sync
```

## Runtime Instructions

On your first boot using the SD Card we just prepared, note that nothing has changed by default. You should have two network interfaces like this (eth0 and eth1):

```sh
root@phyboard-izar-am68x-2:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 28:b5:e8:e2:fc:8f brd ff:ff:ff:ff:ff:ff
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 06:9b:59:68:3d:f2 brd ff:ff:ff:ff:ff:ff
4: main_mcan1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
5: main_mcan13: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
6: main_mcan16: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
7: mcu_mcan0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
```

By default, eth0 corresponds to the X25 RJ45 connector (labeled Ethernet MCU in the schematic) and eth1 corresponds to the X24 RJ45 connector (labeled Ethernet Main in the schematic).

We can actually run the EC-Master-V3.3-Linux-ARM_64Bit-Eval demo on the raw network socket (as-is, without the optomized driver) like this (using X24 here to connect to a Beckhoff EK1100 device).

First, navigate to the unpacked EC-Master Eval package:

```sh
cd ~/EC-Master-V3.3-Linux-ARM_64Bit-Eval/Bin/Linux/aarch64
```

Then run the following:

```sh
root@phyboard-izar-am68x-2:aarch64# LD_LIBRARY_PATH=. ./EcMasterDemo -sockraw eth1 -v 3 -b 4000
0000000000: EcMasterDemo V3.3.2.01 for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000000: Full command line: -sockraw eth1 -v 3 -b 4000
0000000001: EC-Master V3.3.2.01 (Protected) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000002: emllSockRaw(---): V3.3.2.01 (Unrestricted) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000038: EtherCAT network adapter MAC: DA-49-2F-9A-D7-3F
0000000400: Protected version, stop sending ethernet frames after 60 minutes if not licensed!
0000000596: Bus scan successful - 1 slaves found
0000000597: ******************************************************************************
0000000597: Slave ID............: 0x00000000
0000000597: Bus Index...........: 0
0000000597: Bus AutoInc Address.: 0x0000 (   0)
0000000597: Bus Station Address.: 0x0001 (   1)
0000000597: Bus Alias Address...: 0x0000 (   0)
0000000597: Vendor ID...........: 0x00000002 = Beckhoff Automation GmbH
0000000597: Product Code........: 0x044C2C52 = EK1100
0000000597: Revision............: 0x00120000   Serial Number: 0
0000000597: ESC Type............: Beckhoff ET1100 (0x11)  Revision: 0  Build: 3
0000000597: Connection at Port A: yes (to 0x00010000)
0000000597: Connection at Port D: no (to 0xFFFFFFFF)
0000000597: Connection at Port B: no (to 0xFFFFFFFF)
0000000597: Connection at Port C: no (to 0xFFFFFFFF)
0000000597: Line Crossed........: no
0000000597: Line Crossed Flags..: 0x0
0000000597: Cfg Station Address.: 0x0001 (   1)
0000000597: Cfg Device Name.....: Slave_001
0000000597: ******************************************************************************
0000000624: Master state changed from <UNKNOWN> to <INIT>
0000000704: Master state changed from <INIT> to <PREOP>
0000000705: No ENI file provided. EC-Master started with generated ENI file.
0000000705: EcMasterDemo will stop in 600s... 
```

Now, let's enable the optimized support introduced in this meta layer.

Open the bootenv.txt file:

```sh
vi /boot/bootenv.txt
```

Add "k3-am68-phyboard-izar-atemsys.dtbo" to the end of the *overlays=* variable (this variable is a space-separated list of all the device tree overlays you want optionally enabled at runtime). Here is an example of what that can look like:

```sh
overlays=k3-am68-phyboard-izar-lvds-ac200.dtbo k3-am68-phyboard-izar-pwm-fan.dtbo k3-am68-phyboard-izar-atemsys.dtbo
```

Now reboot:

```sh
reboot
```

Upon booting back into Linux, confirm that you have a new atemsys device:

```sh
ls /dev/atemsys
```

* eth0 is now X24 (was X25 before enabling the atemsys device tree overlay).
* X25 is now a dedicated EtherCAT Master interface.

Using EC-Master-V3.3-Linux-ARM_64Bit-Eval, we can exercise the new EtherCAT Master interface like so (here we connect a Beckhoff EK1100 device to the phyCORE-AM68Ax Development Kit's X25 port):

```sh
root@phyboard-izar-am68x-2:aarch64# LD_LIBRARY_PATH=. ./EcMasterDemo -cpswg 1 1 m custom tda4 0 rgmii 1 -v 3 -b 1000
0000000000: EcMasterDemo V3.3.2.01 for Linux_aarch64 Copyright a[  788.836348] atemsys: device_open(0xffff00080338e900)
contis technologies GmbH @ 2026
0000000000: Full command line: [  788.844829] atemsys: mmap: mapped IO memory, Phys:0x46000000 UVirt:0x0000ffffac150000 Size:2097152
-cpswg 1 1 m custom tda4 0 rgmii 1 -v 3 -b 1000
0000000001: EC-Master V3.3.2.01 (Protected) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000002: emllCPSWG(0x00000001): V3.3.2.01 (Unrestricted) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
[  790.619107] atemsys: mmap: mapped IO memory, Phys:0x40f00000 UVirt:0x0000ffffac130000 Size:131072
[  790.729520] atemsys: mmap: mapped DMA memory, Phys:0x0000000080200000 KVirt:0xffff000000200000 UVirt:0x0000ffffac13d000 Size:77824
[  790.741448] atemsys: mmap: mapped DMA memory, Phys:0x000000008017e000 KVirt:0xffff00000017e000 UVirt:0x0000ffffacc0a000 Size:8192
[  790.753121] atemsys: mmap: mapped IO memory, Phys:0x883065000 UVirt:0x0000ffffacc03000 Size:4096
[  790.761942] atemsys: mmap: mapped IO memory, Phys:0x886611000 UVirt:0x0000ffffacc02000 Size:4096
[  790.770729] atemsys: mmap: mapped IO memory, Phys:0x80141000 UVirt:0x0000ffffacc01000 Size:4096
[  790.779429] atemsys: mmap: mapped IO memory, Phys:0x88339d000 UVirt:0x0000ffffacbd6000 Size:4096
[  790.788304] atemsys: mmap: mapped DMA memory, Phys:0x0000000080260000 KVirt:0xffff000000260000 UVirt:0x0000ffffac12d000 Size:65536
[  790.800219] atemsys: mmap: mapped DMA memory, Phys:0x0000000080280000 KVirt:0xffff000000280000 UVirt:0x0000ffffac11a000 Size:77824
0000001978: EtherCAT network adapter MAC: 28-B5-E8-E2-FC-8F
0000002087: Protected version, stop sending ethernet frames after 60 minutes if not licensed!
0000002143: Bus scan successful - 1 slaves found
0000002144: ******************************************************************************
0000002144: Slave ID............: 0x00000000
0000002144: Bus Index...........: 0
0000002144: Bus AutoInc Address.: 0x0000 (   0)
0000002144: Bus Station Address.: 0x0001 (   1)
0000002144: Bus Alias Address...: 0x0000 (   0)
0000002144: Vendor ID...........: 0x00000002 = Beckhoff Automation GmbH
0000002144: Product Code........: 0x044C2C52 = EK1100
0000002144: Revision............: 0x00120000   Serial Number: 0
0000002144: ESC Type............: Beckhoff ET1100 (0x11)  Revision: 0  Build: 3
0000002144: Connection at Port A: yes (to 0x00010000)
0000002144: Connection at Port D: no (to 0xFFFFFFFF)
0000002144: Connection at Port B: no (to 0xFFFFFFFF)
0000002144: Connection at Port C: no (to 0xFFFFFFFF)
0000002144: Line Crossed........: no
0000002144: Line Crossed Flags..: 0x0
0000002144: Cfg Station Address.: 0x0001 (   1)
0000002144: Cfg Device Name.....: Slave_001
0000002144: ******************************************************************************
0000002150: Master state changed from <UNKNOWN> to <INIT>
0000002170: Master state changed from <INIT> to <PREOP>
0000002170: No ENI file provided. EC-Master started with generated ENI file.
0000002170: EcMasterDemo will stop in 600s...
```
