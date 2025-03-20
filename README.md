# Introduction

This projects serves as an example of how to produce a medium image that can boot a fitImage and can be written onto a medium directly using bmaptool. A way of using a single image recipe to pack its rootfs into either a fitImage within a medium image or a medium image with a separate partition rootfs using Yocto only tooling is demonstrated. Having a separate partition rootfs is a common technique used to debug system configuration and quickly redeploy developed applications without recreating an image each time. Finally, a way to add a read/write partition with arbitrary contents to a medium image with RAM based rootfs is demonstrated.

All necessary explanations can be found in source code and configuration files.

# Quickstart

 1. Clone layers using clone.sh (needs to be done once after cloning the project).
 2. Source bitbake using source.sh.
 3. Build an image:
 - - uimg-min: `bitbake uimg-min`
 - - uimg-min-fit: `bitbake mc:uimg-min-fit:uimg-min-fit`
 - - uimg-min-kfit: `bitbake mc:uimg-min-kfit:uimg-min-kfit`
 4. Run qemu: `runqemu nographic`. Qemu nographic can be exited using `Ctrl + a` then `x`.

# Motivation

While there are a couple of examples on how to make a fitImage itself online, there are none which would show how to produce a full fledged medium image that boots fitImage.

## Known flashing methods overview

Here are some vendors providing Yocto solutions that I know of:
 - Xilinx
 - NXP
 - Beagleboards
 - 96boards

**Update**: it turns out, there is a whole [Yocto wiki page](https://wiki.yoctoproject.org/wiki/Project_Users) dedicated to keeping track of companies that use Yocto.

The only one I'm familiar with is Xilinx. Xilinx provides a petalinux toolchain which may build any kind of image you'd prefer:
 - initrd
 - initramfs
 - separate partition rootfs
 - etc.

With Xilinx, assuming SD card/MMC boot, you always need at least a boot partition which contains uboot binary which is loaded through MCU's ROM. Further actions depend on whether you want a RAM or partition based rootfs:
 - for RAM based rootfs you produce an image.ub file which is essentially a fitImage and put it in the boot partition
 - for partition based rootfs you create a second partition on your medium and overwrite it with produced rootfs filesystem image

Source: [PetaLinux Tools Reference Guide UG1144 (v2022.2)](https://www.xilinx.com/support/documents/sw_manuals/xilinx2022_2/ug1144-petalinux-tools-reference-guide.pdf).

From a quick search it seems that 96boards builds a binary image of boot partition and uses fastboot utility from Android to flash boot and rootfs patitions onto its embedded MMC. Source: [Generic OpenEmbedded/Yocto Guide for 96Boards Platforms](https://www.96boards.org/documentation/consumer/guides/open_embedded.md.html).

For NXP I couldn't access the docs exception for the ones from the forum. As an example, a guide for flashing the FRDM-i.MX 91 board uses a program called uuu from github repository mfgtools. The following command is used to flash the image (Source: [FRDM i.MX 91_Board_Flashing.pdf](https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/FRDM-Training/29/1/FRDM%20i.MX%2091_Board_Flashing.pdf)):
```
uuu -b emmc_all imx-boot-imx91evk-sd.bin-flash_singleboot imx-image-full-imx91evk.wic
```

From this syntax it seems that the flashing method is similar to the one used by 96boards.

For Beagleboards there are 2 main solutions. First one is to use fastboot utility. This is suggested in the [quick start](https://docs.beagleboard.org/boards/beaglev/ahead/02-quick-start.html) for BeagleV Ahead. I suppose this implies that this board either maintains a copy of uboot that works at all times with fastboot support or has fastboot support in the ROM which I find to be less likely. The second option is to write an image directly to eMMC. [This forum post](https://forum.beagleboard.org/t/flashing-bbb-emmc-with-yocto-image/32197) suggests BeageBone Black can be put into a state where it exposes its eMMC as a device and can be written to directly. This suggests that there has to be a way to build a wic image. One thing that surprised me is that not only has meta-beagleboard from openembedded layer index not been updated in 12 years on github but it also doesn't have a kickstart script for said wic image to be built. It turns out, beagleboard support has been included into Yocto and said script can be found in meta-yocto-bsp layer: meta-yocto-bsp/wic/beaglebone-yocto.wks. This script creates a medium image that has rootfs as separate partition.

## Conclusion

None of the overviewed solutions use Yocto to produce medium images that use fitImage and can be flashed onto MMC medium directly using bmaptool. This functionality might be necessary for developers who work with boards that don't have a designated flashing utility and want to avoid having to partition their medium manually each time.

# Key principles

Raw Yocto is used much as possible for this project. While a lot of bitbake configuration nastiness may be offset by tools such as [kas](https://github.com/siemens/kas) (go check it out if you aren't using it for your Yocto project yet by the way), this project aims to demonstrate mechanisms used by Yocto to achieve goals stated in introduction.

I've chosen to use Orange Pi Pc as target SBC. I've worked with and know how to do what I set out to do on it. Besides, it has good support for Yocto and it has mainline support from linux kernel, uboot and even qemu (orangepi-pc board definition).

# Limitations

Some stuff may be broken when changing local.conf variables. For example, changing the MACHINE without manually cleaning up deploy artifacts may result in errors.

The images have only been tested using qemu and not real hardware, it's possible that some stuff won't work as intended. Everyone is welcome to test images on real hardware and report the results.

# Images summary

U-boot script is the same for all images. It tries to boot fitImage from boot partition first. If it fails, it then tries to boot using default kernel type and device tree from boot partition and rootfs from separate partition designated to rootfs.

Every fitImage has at least a kernel and a device tree. Any additional contents of a fitImage are specified in respective sections.

## uimg-min

An image with 3 partitions: boot, rootfs, persist. Boot partition contains device tree, u-boot script and kernel.

## uimg-min-fit

An image with 2 partitions: boot and persist. Boot partition contains u-boot script and fitImage with rootfs as a subimage of fitImage.

## uimg-min-kfit

Same as uimg-min-fit except except the rootfs is now a part of kernel within fitImage and not a ramdisk subimage within fitImage. This means in this setup u-boot is no longer aware of existence of initramfs used to initialize the operating system.

## uimg-min-initramfs

An image used to create rootfs for fitImage based images. Has the same rootfs contents as uimg-min. The only reason it exists is that uimg-min can't be used as initramfs without modification. See image recipe for details.

# Building images

The first step is to run clone.sh to clone layers required to build the project. This needs to be done once right after the project has been cloned.

The second step is to run `. ./source.sh` to setup build environment. This script uses correct template to generate default local.conf and bblayers.conf and also sets the correct build directory.

After the environment has been set up, use bitbake to build an image. For uimg-min-fit and uimg-min-kfit a respective multiconfig must be specified. The name of multiconfig is the same as image name.

**uimg-min**:
```
bitbake uimg-min
```
**uimg-min-fit**:
```
bitbake mc:uimg-min-fit:uimg-min-fit
```
**uimg-min-kfit**:
```
bitbake mc:uimg-min-kfit:uimg-min-kfit
```
**uimg-min-initramfs**:
```
bitbake uimg-min-initramfs
```

Building uimg-min-initramfs shouldn't be necessary but it's possible. Image uimg-min-initramfs is used as ramdisk for uimg-min-fit and uimg-min-kfit.

# Flashing images

The images are flashed using bmaptool utility. It can be obtained by installing bmap-tools package. Final name of image file is determined by IMAGE_LINK_NAME variable. For example, if you want to flash image <uimg-min-fit> to medium </dev/sda> your command for that would be (assuming current working directory is project root):
```
# helper variables
targ_img_name="uimg-min-fit"
targ_disk="/dev/sda"
targ_img_basepath="images/${targ_img_name}-orange-pi-pc.rootfs"
# the command itself
sudo bmaptool copy --bmap ${targ_img_basepath}.wic.bmap ${targ_img_basepath}.wic ${targ_disk}
```

**uimg-min**:
```
sudo bmaptool copy --bmap images/uimg-min-orange-pi-pc-qemu.rootfs.wic.bmap images/uimg-min-orange-pi-pc-qemu.rootfs.wic /dev/sdX
```
**uimg-min-fit**:
```
sudo bmaptool copy --bmap images/uimg-min-fit-orange-pi-pc-qemu.rootfs.wic.bmap images/uimg-min-fit-orange-pi-pc-qemu.rootfs.wic /dev/sdX
```
**uimg-min-kfit**:
```
sudo bmaptool copy --bmap images/uimg-min-kfit-orange-pi-pc-qemu.rootfs.wic.bmap images/uimg-min-kfit-orange-pi-pc-qemu.rootfs.wic /dev/sdX
```

# Q&A

## Why use fixed size for every partition?

It would be prefereable to have rootfs + some extra space but in wic it's either set partition size to rootfs size or provide your own partition size. One possible solution to that is to use resize-helper from 96boards-tools which can be added through meta-96boards layer. Script resize-helper extends the last partition on a medium to occupy all of the unused space. Armbian does the same thing.

## Shouldn't TMPDIR be different for every multiconfig?

It largely depends on the kind of changes made by a multiconfig. The way I see it is the only case where this is necessary is if a rebuild is going to trigger a large amount of rebuilds. Even then, there are exceptions. For example, if your multiconfig changes MACHINE your build artifacts such as licenses and packages are already covered because they have MACHINE as a part of their path at some with exception being DEPLOY_DIR_IMAGE which isn't hard to fix.

# TODO

 - u-boot reports ramdisk size of fitImage to be 95 bytes. 95 is such a funny number, where does it even come from. Image contains a single empty init file. It's possible that this is because cpio.gz is being rebuilt without rebuilding rootfs even after rm_work removes it. After a couple of rebuilds an image was built correctly and I was able to boot it. Weird.
 - With multiconfig bitbake displays recipe name for u-boot as u-boot-1_2024.01-r0 for some reason.
 - I can't see the stdout of processes launched by init, only the kernel messages.

# Glossary

 - medium image: A binary file that can be written byte by byte onto a medium which will make said medium a valid bootable device.
 - filesystem image: A filesystem created as a file instead of as a partition on some medium. As an example, it can be created by allocating an empty file of size enough to store a filesystem and then calling one of mkfs subutils to partition it. Such file can be used as either an intermediate storage for a partition to be written onto a medium image or as a complete medium image.
 - fitImage: Flattened uImage Tree (FIT), a binary format that may incorporate a set of different kernels, device trees, ramdisks and some other subimage types that can be loaded depending on target machine. fitImage format started as a part of uboot and has since grown into a separate project. In Yocto there are [several limitations](https://docs.yoctoproject.org/ref-manual/classes.html#kernel-fitimage) imposed on fitImage files due to the way Yocto builds rootfs. For one, only a single ramdisk entry can be incorporated into a fitImage produced by the kernel-fitimage class.
 - rootfs: A filesystem image with all the files that constitute an operating system.
 - partition based rootfs: A rootfs that is presented as a partition on some medium.
 - RAM based rootfs: Also called ramdisk in fitImage subimage types. A rootfs that is unpacked in RAM before being run. This rootfs storage method prevents damage to rootfs in case of sudden power interruption since non-volatile rootfs storage is never written to during runtime and is mostly used with embedded systems.
 - SBC: Single Board Computer.

# Resources

 - [Yocto variables](https://docs.yoctoproject.org/next/ref-manual/variables.html).
 - [Bitbake variables](https://docs.yoctoproject.org/bitbake/dev/bitbake-user-manual/bitbake-user-manual-ref-variables.html).
 - [OpenEmbedded Layer Index](https://layers.openembedded.org/layerindex/branch/master/layers/).
