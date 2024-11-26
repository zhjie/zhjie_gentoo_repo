# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# inherit dist-kernel-utils linux-info mount-boot python-any-r1 savedconfig
inherit unpacker

SRC_URI="https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release/apple-bcm-firmware-14.0-1-any.pkg.tar.zst"

KEYWORDS="~amd64"

DESCRIPTION="Apple bcm firmware files"
HOMEPAGE="https://www.t2linux.org/"

LICENSE=""
SLOT="0"
IUSE=""

#add anything else that collides to this
RDEPEND=""

QA_PREBUILT="*"

src_unpack() {
	_unpacker "apple-bcm-firmware-14.0-1-any.pkg.tar.zst"
	mkdir "${WORKDIR}/${P}/"
	mv usr/lib "${WORKDIR}/${P}/"
}

src_install() {
	cp -R "${S}/lib" "${D}/" || die "Install failed!"
}
