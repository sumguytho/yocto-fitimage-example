# This image is a placeholder to generate a medium image
# what has all required partitions. The real target for
# fitImage to be generated is virtual/kernel.
SUMMARY = "A placeholder recipe that builds a medium image which in turn boots fitImage."
LICENSE = "MIT"

# Inherit image because we need its wic image generation capabilities and
# because we also don't build anything in a conventional manner.
inherit image
# Only interested in wic image as a result of this recipe. All the other artifacts will
# be built by dependencies.
IMAGE_FSTYPES = "wic wic.bmap"
# Which is why our own rootfs should be empty. We will be using deploy artifacts of other
# recipes anyway. Which recipes exactly depends on multiconfig.
PACKAGE_INSTALL = ""
