COMPATIBLE_MACHINE .= "|phyboard-izar-am68x-2"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
	file://0001-izar-dtso-add-atemsys-device-tree-overlay.patch \
"
