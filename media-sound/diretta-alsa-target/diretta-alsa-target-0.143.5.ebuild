# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta Alsa Target"
HOMEPAGE="https://www.diretta.link/preview/"

X86_VER="2025.04.25-2"
ARM_VER="2025.04.25-1"
X86_TARGET="diretta-alsa-target-${X86_VER}-x86_64.pkg.tar.zst"
ARM_TARGET="diretta-alsa-target-${ARM_VER}-aarch64.pkg.tar.xz"

SRC_URI="
    amd64? ( https://www.audio-linux.com/repo/${X86_TARGET} )
    arm64? ( https://www.audio-linux.com/repo_aarch64/${ARM_TARGET} )
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
	if use arm64; then
	        _unpacker "${ARM_TARGET}"
	fi
	if use amd64; then
		_unpacker "${X86_TARGET}"
	fi
	mkdir -p "${WORKDIR}/${P}"
	mv -v opt/ "${WORKDIR}/${P}"
}

src_install() {
	find .
	insopts -m755
	doins -r *
	newinitd "${FILESDIR}/diretta-alsa-target.init.d" "diretta-alsa-target"
}
