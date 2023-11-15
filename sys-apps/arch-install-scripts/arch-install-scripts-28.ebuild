# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="nqptp is a companion application to Shairport Sync and provides timing information for AirPlay 2 operation."
HOMEPAGE="https://github.com/archlinux/arch-install-scripts"
SRC_URI="https://github.com/archlinux/arch-install-scripts/archive/refs/tags/v28.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	default
	sed -i -e "s|(BINPROGS) man|(BINPROGS)|g" ${WORKDIR}/${P}/Makefile
}

src_install() {
	dobin pacstrap
	dobin arch-chroot
	dobin genfstab
}
