# Introduction

This projects serves as an example of how to produce a medium image that can boot a fitImage and can be written onto a medium directly using bmaptool. A way of using a single image recipe to pack its rootfs into either a fitImage within a medium image or a medium image with a separate partition rootfs using yocto only tooling is demonstrated. Having a separate partition rootfs is a common technique used to debug system configuration and quickly redeploy developed applications without recreating an image each time. Finally, a way to add a read/write partition with arbitrary contents to a medium image with RAM based rootfs is demonstrated.

# Motivation

While there are a couple of examples on how to make a fitImage itself online, there are none which would show how to produce a full fledged medium image that boots fitImage.

## Known flashing methods overview

Here are some vendors providing yocto solutions that I know of:
 - Xilinx
 - NXP
 - Beagleboards
 - 96boards

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

## Conclusion

None of the overviewed solutions use yocto to produce images that can be flashed onto MMC medium directly using bmaptool. This functionality might be necessary for developers who work with boards that don't have a designated flashing utility and want to avoid having to partition their medium manually.

# Key principles

Raw yocto is used much as possible for this project. While a lot of bitbake configuration nastiness may be offset by tools such as [kas](https://github.com/siemens/kas) (go check it out if you aren't using it for your yocto project yet by the way), this project aims to demonstrate mechanisms used by yocto to achieve goals stated in introduction.

# Generating images

The first step is to use clone.sh script to clone layers required to build the project.

# Glossary

 - medium image: A binary file that can be written byte by byte onto a medium which will make said medium a valid bootable device.
 - filesystem image: A filesystem created as a file instead of as a partition on some medium. As an example, it can be created by allocating an empty file of size enough to store a filesystem and then calling one of mkfs subutils to partition it. Such file can be used as either an intermediate storage for a partition to be written onto a medium image or as a complete medium image.
 - fitImage: Flattened uImage Tree (FIT), a binary format that may incorporate a set of different kernels, device trees, ramdisks and some other subimage types that can be loaded depending on target machine. fitImage format is supported by uboot. In yocto there are [several limitations](https://docs.yoctoproject.org/ref-manual/classes.html#kernel-fitimage) imposed on fitImage files due to the way yocto builds rootfs. For one, only a single ramdisk entry can be incorporated into a fitImage produce by the kernel-fitimage class.
 - rootfs: A filesystem image with all the files that constitute an operating system.
 - partition based rootfs: A rootfs that is presented as a partition on some medium.
 - RAM based rootfs: Also called ramdisk in fitImage subimage types. A rootfs that is unpacked in RAM before being run. This rootfs storage method prevents damage to rootfs in case of sudden power interruption since non-volatile rootfs storage is never written to during runtime and is mostly used with embedded systems.
