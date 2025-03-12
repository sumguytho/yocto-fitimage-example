# The difference between this image and uimg-min-fit is that this one
# incorporates ramdisk into kernel instead of fitImage.
# Kernel always comes with an inline ramdisk filesystem even if nothing is
# placed into it. Including image as a part of kernel might mean the image
# has to be compatible with GPLv2 license since the image essentially becomes
# a part of the kernel.
require recipes-core/images/uimg-min-fit.bb
