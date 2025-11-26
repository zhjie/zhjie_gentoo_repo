# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta Alsa Target"
HOMEPAGE="https://www.diretta.link/preview/"

ARM_TARGET="diretta-alsa-target-146_7-1-aarch64.pkg.tar.xz"

SRC_URI="
	https://www.audio-linux.com/repo_aarch64/${ARM_TARGET}
"

KEYWORDS="~amd64 ~arm64"
SLOT="0"
LICENSE="CDDL"
IUSE=""

RDEPEND=">=dev-libs/openssl-3.0
	net-misc/curl
	media-libs/alsa-lib
	sys-libs/zlib
	net-dns/libidn2
	>=dev-libs/libunistring-1.2
"

src_unpack() {
        _unpacker "${ARM_TARGET}"
	mkdir -p "${WORKDIR}/${P}"
	mv -v opt/ "${WORKDIR}/${P}"
}

src_install() {
	find .
	insopts -m755
	doins -r *
	newinitd "${FILESDIR}/diretta-alsa-target.init.d" "diretta-alsa-target"
}
