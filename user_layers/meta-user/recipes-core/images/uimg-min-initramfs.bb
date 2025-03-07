# This image is what's actually going to be unpacked into RAM.
# This image shouldn't have the kernel since it will be put into a fitImage.
require recipes-core/images/uimg-min.bb

# WKS_FILE_DEPENDS dependencies are added with the assumption that an image
# is going to be built independently, not as a part of something.
# In fact, core-image-minimal-initramfs does the same except it uses
# PACKAGE_EXCLUDE for this purpose.
DEPENDS:remove = "${WKS_FILE_DEPENDS}"
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
