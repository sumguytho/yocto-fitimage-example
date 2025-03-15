# This file is a modified version of meta-sunxi/recipes-bsp/u-boot/files/arm/boot.cmd.
# Try Booting fitImage, fallback to separate partition rootfs.

echo "## Trying to boot fitImage"
bootpart=0:1
user_fitimage_name=@USER_FITIMAGE_NAME@
user_fitimage_loadaddr=@USER_FITIMAGE_LOADADDR@
load mmc ${bootpart} ${user_fitimage_loadaddr} ${user_fitimage_name}
setenv bootargs console=${console} console=tty1 rootwait ${extra}
bootm ${user_fitimage_loadaddr}

echo "## Trying to boot rootfs mmc partition"
rootdev=mmcblk0p2
if itest.b *0x28 == 0x02 ; then
	# U-Boot loaded from eMMC or secondary SD so use it for rootfs too
	echo "U-boot loaded from eMMC or secondary SD"
	rootdev=mmcblk1p2
fi
setenv bootargs console=${console} console=tty1 root=/dev/${rootdev} rootwait panic=10 ${extra}
load mmc 0:1 ${fdt_addr_r} ${fdtfile} || load mmc 0:1 ${fdt_addr_r} boot/allwinner/${fdtfile}
load mmc 0:1 ${kernel_addr_r} zImage || load mmc 0:1 ${kernel_addr_r} boot/zImage || load mmc 0:1 ${kernel_addr_r} uImage || load mmc 0:1 ${kernel_addr_r} boot/uImage
bootz ${kernel_addr_r} - ${fdt_addr_r} || bootm ${kernel_addr_r} - ${fdt_addr_r}

echo "## Couldn't boot"
