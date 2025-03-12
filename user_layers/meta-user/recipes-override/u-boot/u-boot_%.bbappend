FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://nousb.cfg \
    file://bootm_extra_mem.cfg \
    file://myboot.cmd \
"

do_subst_bootcmd() {
    # I get it, my version of boot.cmd isn't fetched because meta-sunxi uses
    # MACHINEOVERRIDES for that file which means I have to resort to ugly trickery.
    if [ -e "boot.cmd" ]; then
        mv boot.cmd boot.cmd.bak
        mv myboot.cmd boot.cmd
    fi
    sed -i "s/@USER_FITIMAGE_NAME@/${USER_FITIMAGE_NAME}/g" boot.cmd
    sed -i "s/@USER_FITIMAGE_LOADADDR@/${USER_FITIMAGE_LOADADDR}/g" boot.cmd
}
# By default tasks start at BUILDDIR, I think.
do_subst_bootcmd[dirs] = "${WORKDIR}"
addtask do_subst_bootcmd before do_compile after do_unpack
