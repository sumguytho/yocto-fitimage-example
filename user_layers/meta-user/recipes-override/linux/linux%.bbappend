kernel_do_deploy:append() {
    # Create a symlink USER_FITIMAGE_NAME that points to a fitImage that we intend to boot.
    # INITRAMFS_IMAGE_BUNDLE controls which fitImage we want. Worst case scenario is we create
    # a broken symlink that won't be used.
    if [ "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
        ln -sf fitImage-bundle $deployDir/${USER_FITIMAGE_NAME}
    else
        ln -sf fitImage-${INITRAMFS_IMAGE_NAME}-${KERNEL_FIT_NAME}${KERNEL_FIT_BIN_EXT} $deployDir/${USER_FITIMAGE_NAME}
    fi
}
