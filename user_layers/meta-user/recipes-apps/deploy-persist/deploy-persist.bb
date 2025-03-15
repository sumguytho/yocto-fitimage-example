SUMMARY = "A recipe that creates a directory used to populate persist partition."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "0.1.0"

SRC_URI = "file://persist/"

S = "${WORKDIR}"

do_install() {
    # This directory needs to exist to be a valid mountpoint.
    install -d ${D}/persist
}

inherit deploy

do_deploy() {
    cp -r --no-preserve=ownership ${WORKDIR}/persist ${DEPLOYDIR}/
}
addtask do_deploy before do_build after do_fetch

FILES:${PN} += "/persist"
