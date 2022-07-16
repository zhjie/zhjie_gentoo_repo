# Copyright (c) 2018 alntonello <antonellocaroli@gmail.com>
# License: GPL v3+
# NO WARRANTY

EAPI=7

inherit

DESCRIPTION="Raspberry PI boot loader and firmware, for 64-bit mode"
HOMEPAGE="https://github.com/raspberrypi/firmware"
UPSTREAM_PV="${PV/_p/+}"
DOWNLOAD_PV="${PV/_p/-}"
SRC_URI="https://github.com/raspberrypi/firmware/archive/${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2 raspberrypi-videocore-bin Broadcom"
SLOT="0"
KEYWORDS="~arm64"
IUSE="pitop +dtbo"
RESTRICT="mirror binchecks strip"

DEPEND=""
RDEPEND="
	${DEPEND}"

S="${WORKDIR}/firmware-${UPSTREAM_PV}"

pkg_preinst() {
	mount /boot
	if ! grep "${ROOT%/}/boot" /proc/mounts >/dev/null 2>&1; then
		ewarn "${ROOT%/}/boot is not mounted, the files might not be installed at the right place"
	fi
}
src_prepare() {
	default
}

src_install() {
	insinto /boot
	cd boot || die
	doins start4.elf
	doins start4cd.elf
	doins start4db.elf
	doins start4x.elf
	# allow for the dtbos to be provided by the kernel package
	#if use dtbo; then
	#	doins -r overlays
	#fi
	doins fixup4.dat
	doins fixup4cd.dat
	doins fixup4db.dat
	doins fixup4x.dat
	doins *.bin
	doins *.broadcom
}
