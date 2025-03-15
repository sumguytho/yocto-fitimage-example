SUMMARY = "A test recipe that creates directory for persist partition, adds a simple app launched at boot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "0.1.0"

SRC_URI = "\
    file://Makefile \
    file://test-app.cpp \
    file://test-app.init \
"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 test-app ${D}${bindir}/
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 test-app.init ${D}${sysconfdir}/init.d/test-app
}

inherit update-rc.d

INITSCRIPT_NAME = "test-app"
INITSCRIPT_PARAMS = "defaults"
