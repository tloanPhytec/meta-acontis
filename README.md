[![Brand](https://img.shields.io/badge/PHYTEC-teal)](https://www.phytec.com)
[![Brand](https://img.shields.io/badge/Acontis-orange)](https://www.acontis.com/en/)
[![Platform](https://img.shields.io/badge/Platform-phyCORE--i.MX8MPlus-teal)](https://www.phytec.com/product/phycore-imx8m-plus/)
[![Documentation](https://img.shields.io/badge/Linux-BSP--Yocto--NXP--i.MX8MP--PD24.1.0-purple)](https://www.phytec.de/produkte/system-on-modules/phycore-imx-8m-plus-plugged/#section-5)
[![Stack](https://img.shields.io/badge/Stack-Acontis_EC--Master-red)](https://www.acontis.com/en/ethercat-master.html)
[![Context](https://img.shields.io/badge/Context-EtherCAT_Technology-red)](https://www.ethercat.org/default.htm)

This Yocto Meta Layer serves to configure the phyCORE-i.MX8MPlus Development Kit's FEC Ethernet interface with an optimized atemsys kernel module that grants direct access to hardware and improves the performance of the EtherCAT Master Stack Software, EC-Master from Acontis. 

This Meta Layer was tested in combination with the following software components:

* BSP-Yocto-NXP-i.MX8MP-PD24.1.0 (Scarthgap)
* EC-Master-V3.3-Linux-ARM_64Bit-Eval

  * Due to licensing, this must be aquired from Acontis directly and then added to your root filesystem: https://www.acontis.com/en/ethercat-master.html

## BSP Integration

In order to evaluate this Meta Layer on your phyCORE-i.MX8MPlus Development Kit, you must have first built the default BSP per the following development guide:

https://phytec.github.io/doc-bsp-yocto/bsp/imx8/imx8mp/pd24.1.0_nxp.html#building-the-bsp

Navigate to your BSP's sources directory:

```sh
cd $BUILDDIR/../sources
```

Clone this repo and branch recursively so that the submodules are cloned as well:

```sh
git clone --recursive https://github.com/tloanPhytec/meta-acontis.git -b scarthgap-imx8mp
```

Enable the layer in your build:

```sh
cd $BUILDDIR
bitbake-layers add-layer ../sources/meta-acontis
```

Rebuild your target's image with bitbake:

```sh
MACHINE=phyboard-pollux-imx8mp-3 DISTRO=ampliphy-vendor bitbake phytec-headless-image
```

Flash the resulting image to an SD Card and then expand the root filesystem:

```sh
# identify your SD Card
mount

umount /dev/sdX*
sudo bmaptool copy phytec-headless-image-phyboard-pollux-imx8mp-3.rootfs.wic.xz /dev/sdX
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
root@phyboard-pollux-imx8mp-3:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 50:2d:f4:2b:2b:b3 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::522d:f4ff:fe2b:2bb3/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 50:2d:f4:2b:2b:b4 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::522d:f4ff:fe2b:2bb4/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
5: can1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP group default qlen 10
    link/can
```

By default, eth0 corresponds to the X8 RJ45 connector (labeled "Ethernet1" on the PCB silkscreen) and eth1 corresponds to the X9 RJ45 connector (labeled "Ethernet0" on the PCB silkscreen).

We can actually run the EC-Master-V3.3-Linux-ARM_64Bit-Eval demo on the raw network socket (as-is, without the optomized driver) like this (**using X8 here to connect to a Beckhoff EK1100 device**).

First, navigate to the unpacked EC-Master Eval package:

```sh
cd ~/EC-Master-V3.3-Linux-ARM_64Bit-Eval/Bin/Linux/aarch64
```

Then run the following:

```sh
root@phyboard-pollux-imx8mp-3:aarch64# LD_LIBRARY_PATH=. ./EcMasterDemo -sockraw eth0 -v 3 -b 4000
0000000000: EcMasterDemo V3.3.2.01 for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000000: Full command line: -sockraw eth0 -v 3 -b 4000
0000000001: EC-Master V3.3.2.01 (Protected) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000002: emllSockRaw(---): V3.3.2.01 (Unrestricted) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000051: EtherCAT network adapter MAC: 50-2D-F4-2B-2B-B3
0000000415: Protected version, stop sending ethernet frames after 60 minutes if not licensed!
0000000609: Bus scan successful - 1 slaves found
0000000612: ******************************************************************************
0000000612: Slave ID............: 0x00000000
0000000612: Bus Index...........: 0
0000000612: Bus AutoInc Address.: 0x0000 (   0)
0000000612: Bus Station Address.: 0x0001 (   1)
0000000612: Bus Alias Address...: 0x0000 (   0)
0000000612: Vendor ID...........: 0x00000002 = Beckhoff Automation GmbH
0000000612: Product Code........: 0x044C2C52 = EK1100
0000000612: Revision............: 0x00120000   Serial Number: 0
0000000612: ESC Type............: Beckhoff ET1100 (0x11)  Revision: 0  Build: 3
0000000612: Connection at Port A: yes (to 0x00010000)
0000000612: Connection at Port D: no (to 0xFFFFFFFF)
0000000612: Connection at Port B: no (to 0xFFFFFFFF)
0000000612: Connection at Port C: no (to 0xFFFFFFFF)
0000000612: Line Crossed........: no
0000000612: Line Crossed Flags..: 0x0
0000000612: Cfg Station Address.: 0x0001 (   1)
0000000612: Cfg Device Name.....: Slave_001
0000000612: ******************************************************************************
0000000637: Master state changed from <UNKNOWN> to <INIT>
0000000717: Master state changed from <INIT> to <PREOP>
0000000720: No ENI file provided. EC-Master started with generated ENI file.
0000000720: EcMasterDemo will stop in 600s...
```

Now, let's enable the optimized support introduced in this meta layer.

Open the bootenv.txt file:

```sh
vi /boot/bootenv.txt
```

Add "#conf-imx8mp-phyboard-pollux-atemsys.dtbo" to the end of the *overlays=* variable (this variable is a '#'-separated list of all the device tree overlays you want optionally enabled at runtime. Because the overlays are packaged within the kernel fitImage, we also must preffix these with 'conf-'). Here is an example of what that can look like:

```sh
overlays=conf-imx8mp-phyboard-pollux-peb-av-10.dtbo#conf-imx8mp-phyboard-pollux-atemsys.dtbo
```

Now reboot:

```sh
reboot
```

Upon booting back into Linux, confirm that you have a new atemsys device:

```sh
ls /dev/atemsys
```

* eth0 is now X9 (was X8 before enabling the atemsys device tree overlay).
* X8 is now a dedicated EtherCAT Master interface.

Using EC-Master-V3.3-Linux-ARM_64Bit-Eval, we can exercise the new EtherCAT Master interface like so (here we connect a Beckhoff EK1100 device to the hyCORE-i.MX8MPlus Development Kit's X8 port):

```sh
root@phyboard-pollux-imx8mp-3:~# LD_LIBRARY_PATH=. ./EcMasterDemo -fslfec 1 1 custom imx8mp rgmii 0 -v 3 -b 1000
-sh: ./EcMasterDemo: No such file or directory
root@phyboard-pollux-imx8mp-3:~# cd EC-Master-V3.3-Linux-ARM_64Bit-Eval/
Bin/            CMakeLists.txt  Doc/            EcVersion.txt   Examples/       License.txt     SBOM/           SDK/            Sources/        Workspace/      yocto-acontis/
root@phyboard-pollux-imx8mp-3:~# cd EC-Master-V3.3-Linux-ARM_64Bit-Eval/Bin/Linux/aarch64
root@phyboard-pollux-imx8mp-3:aarch64# LD_LIBRARY_PATH=. ./EcMasterDemo -fslfec 1 1 custom imx8mp rgmii 0 -v 3 -b 1000
0000000000: EcMasterDemo V3.3.2.01 for Linux_aarch64 Copyright a[   29.673586] atemsys: device_open(0xffff00000486d500)
contis technologies GmbH @ 2026
0000000000: Full command line: -fslfec 1 1 custom imx8mp rgmii 0 -v 3 -b 1000
0000000001: EC-Master V3.3.2.01 (Protected) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
0000000004: emllFslFec(0x00000001): V3.3.2.01 (Unrestricted) for Linux_aarch64 Copyright acontis technologies GmbH @ 2026
[   30.180206] atemsys: mmap: mapped IO memory, Phys:0x30380000 UVirt:0x0000ffff88945000 Size:65536
[   30.189060] atemsys: mmap: mapped IO memory, Phys:0x30350000 UVirt:0x0000ffff88910000 Size:65536
[   30.197931] atemsys: mmap: mapped IO memory, Phys:0x30be0000 UVirt:0x0000ffff89273000 Size:4096
[   31.988903] atemsys: mmap: mapped DMA memory, Phys:0x0000000098580000 KVirt:0xffff800084525000 UVirt:0x0000ffff888d7000 Size:299008
0000002333: EtherCAT network adapter MAC: 50-2D-F4-2B-2B-B3
0000002442: Protected version, stop sending ethernet frames after 60 minutes if not licensed!
0000002497: Bus scan successful - 1 slaves found
0000002497: ******************************************************************************
0000002497: Slave ID............: 0x00000000
0000002497: Bus Index...........: 0
0000002497: Bus AutoInc Address.: 0x0000 (   0)
0000002497: Bus Station Address.: 0x0001 (   1)
0000002497: Bus Alias Address...: 0x0000 (   0)
0000002497: Vendor ID...........: 0x00000002 = Beckhoff Automation GmbH
0000002497: Product Code........: 0x044C2C52 = EK1100
0000002497: Revision............: 0x00120000   Serial Number: 0
0000002497: ESC Type............: Beckhoff ET1100 (0x11)  Revision: 0  Build: 3
0000002497: Connection at Port A: yes (to 0x00010000)
0000002497: Connection at Port D: no (to 0xFFFFFFFF)
0000002497: Connection at Port B: no (to 0xFFFFFFFF)
0000002497: Connection at Port C: no (to 0xFFFFFFFF)
0000002497: Line Crossed........: no
0000002498: Line Crossed Flags..: 0x0
0000002498: Cfg Station Address.: 0x0001 (   1)
0000002498: Cfg Device Name.....: Slave_001
0000002498: ******************************************************************************
0000002504: Master state changed from <UNKNOWN> to <INIT>
0000002524: Master state changed from <INIT> to <PREOP>
0000002525: No ENI file provided. EC-Master started with generated ENI file.
0000002525: EcMasterDemo will stop in 600s...
```
