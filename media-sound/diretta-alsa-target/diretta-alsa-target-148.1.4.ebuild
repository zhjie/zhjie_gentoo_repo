# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker
MY_PV_BASE="$(ver_cut 1)_$(ver_cut 2)"
MY_MINOR="$(ver_cut 3)"

DESCRIPTION="Linux Diretta Alsa Target"
HOMEPAGE="https://www.diretta.link/preview/"

SRC_URI="
	arm64? ( https://www.audio-linux.com/repo_aarch64/diretta-alsa-target-${MY_PV_BASE}-${MY_MINOR}-aarch64.pkg.tar.xz )
	amd64? ( https://www.audio-linux.com/ftp/temp/diretta_v2/diretta-alsa-target-${MY_PV_BASE}-${MY_MINOR}-x86_64.pkg.tar.zst )
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
