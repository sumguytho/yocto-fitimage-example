# Transparent about stealing from openembedded from get go.
# This is a usual separate partition rootfs + boot partition image.
# Images like this are convenient for debugging.
# This image also serves as a base for initramfs image used by fitImages
# which means all changes to rootfs must be done in this recipe.
require recipes-core/images/core-image-minimal.bb

IMAGE_FSTYPES = "wic wic.bmap"

IMAGE_INSTALL += " \
    test-app \
    deploy-persist \
"
