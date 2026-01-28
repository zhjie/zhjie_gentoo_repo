# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker
MY_PV=$(ver_rs 1 '_')

DESCRIPTION="Linux Diretta Alsa Target"
HOMEPAGE="https://www.diretta.link/preview/"

ARM_TARGET="diretta-alsa-target-${MY_PV}-1-aarch64.pkg.tar.xz"
X86_TARGET="diretta-alsa-target-${MY_PV}-1-x86_64.pkg.tar.zst"

SRC_URI="
	arm64? ( https://www.audio-linux.com/repo_aarch64/${ARM_TARGET} )
	amd64? ( https://www.audio-linux.com/ftp/temp/diretta_v2/${X86_TARGET} )
"

KEYWORDS="amd64 arm64"
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
	unpacker_src_unpack
	mv opt/ "${WORKDIR}/${P}"
}

src_install() {
	insinto "/opt/"
	insopts -m755
	doins -r *
	newinitd "${FILESDIR}/diretta-alsa-target.init.d" "diretta-alsa-target"
}
