FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:phyboard-pollux-imx8mp-3 = "\
	file://0001-pollux-dtso-add-atemsys-device-tree-overlay.patch \
"
