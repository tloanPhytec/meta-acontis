FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:phyboard-izar-am68x-2 = "\
	file://0001-izar-dtso-add-atemsys-device-tree-overlay.patch \
"
