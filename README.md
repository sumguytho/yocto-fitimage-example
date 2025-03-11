# Introduction

This projects serves as an example of how to produce a medium image that can boot a fitImage and can be written onto a medium directly using bmaptool. A way of using a single image recipe to pack its rootfs into either a fitImage within a medium image or a medium image with a separate partition rootfs using Yocto only tooling is demonstrated. Having a separate partition rootfs is a common technique used to debug system configuration and quickly redeploy developed applications without recreating an image each time. Finally, a way to add a read/write partition with arbitrary contents to a medium image with RAM based rootfs is demonstrated.

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

For Beagleboards there are 2 main solutions. First one is to use fastboot utility. This is suggested in the [quick start](https://docs.beagleboard.org/boards/beaglev/ahead/02-quick-start.html) for BeagleV Ahead. I suppose this implies that this board either maintains a copy of uboot that works at all times with fastboot support or has fastboot support in the ROM which I find to be less likely. The second option is to write an image directly to eMMC. [This forum post](https://forum.beagleboard.org/t/flashing-bbb-emmc-with-yocto-image/32197) suggests BeageBone Black can be put into a state where it exposes its eMMC as a device and can be written to directly. This suggests that there has to be a way to generate a wic image. One thing that surprised me is that not only has meta-beagleboard from openembedded layer index not been updated in 12 years on github but it also doesn't have a kickstart script for said wic image to be generated. It turns out, beagleboard support has been included into Yocto and said script can be found in meta-yocto-bsp layer: meta-yocto-bsp/wic/beaglebone-yocto.wks. This script creates a medium image that has rootfs as separate partition.

## Conclusion

None of the overviewed solutions use Yocto to produce medium images that use fitImage and can be flashed onto MMC medium directly using bmaptool. This functionality might be necessary for developers who work with boards that don't have a designated flashing utility and want to avoid having to partition their medium manually each time.

# Key principles

Raw Yocto is used much as possible for this project. While a lot of bitbake configuration nastiness may be offset by tools such as [kas](https://github.com/siemens/kas) (go check it out if you aren't using it for your Yocto project yet by the way), this project aims to demonstrate mechanisms used by Yocto to achieve goals stated in introduction.

I've chosen to use Orange Pi Pc as target SBC. I've worked with and know how to do what I set out to do on it. Besides, it has good support for Yocto and it has mainline support from linux kernel, uboot and even qemu (orangepi-pc board definition).

# Generating images

The first step is to run clone.sh to clone layers required to build the project. The second step is to run `. ./source.sh` to setup build environment.

Generating uimg-min-initramfs doesn't require any multiconfig. This shouldn't be necessary though, since this image is made to be included into other images as ramdisk.
Generating fitImage: `bitbake mc:uimg-min-fit:uimg-min-fit`.

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

# Limitations

Some stuff may be broken when changing local.conf variables. For example, changing the MACHINE without manually cleaning up deploy artifacts may result in errors.

# TODO

 - Figure out how to test uboot stuff using qemu. Make qemu support a standalone config that can be enabled in local.conf instead of a separate MACHINE.

# Q&A

## Why use fixed size for every partition?

It would be prefereable to have rootfs + some extra space but in wic it's either set partition size to rootfs size or provide your own partition size. One possible solution to that is to use resize-helper from 96boards-tools which can be added through meta-96boards layer. Script resize-helper extends the last partition on a medium to occupy all of the unused space. Armbian does the same thing.

# Glossary

 - medium image: A binary file that can be written byte by byte onto a medium which will make said medium a valid bootable device.
 - filesystem image: A filesystem created as a file instead of as a partition on some medium. As an example, it can be created by allocating an empty file of size enough to store a filesystem and then calling one of mkfs subutils to partition it. Such file can be used as either an intermediate storage for a partition to be written onto a medium image or as a complete medium image.
 - fitImage: Flattened uImage Tree (FIT), a binary format that may incorporate a set of different kernels, device trees, ramdisks and some other subimage types that can be loaded depending on target machine. fitImage format is supported by uboot. In Yocto there are [several limitations](https://docs.yoctoproject.org/ref-manual/classes.html#kernel-fitimage) imposed on fitImage files due to the way Yocto builds rootfs. For one, only a single ramdisk entry can be incorporated into a fitImage produce by the kernel-fitimage class.
 - rootfs: A filesystem image with all the files that constitute an operating system.
 - partition based rootfs: A rootfs that is presented as a partition on some medium.
 - RAM based rootfs: Also called ramdisk in fitImage subimage types. A rootfs that is unpacked in RAM before being run. This rootfs storage method prevents damage to rootfs in case of sudden power interruption since non-volatile rootfs storage is never written to during runtime and is mostly used with embedded systems.
 - SBC: Single Board Computer.

# Resources

 - [Yocto variables](https://docs.yoctoproject.org/next/ref-manual/variables.html).
 - [Bitbake variables](https://docs.yoctoproject.org/bitbake/dev/bitbake-user-manual/bitbake-user-manual-ref-variables.html).
 - [OpenEmbedded Layer Index](https://layers.openembedded.org/layerindex/branch/master/layers/).
