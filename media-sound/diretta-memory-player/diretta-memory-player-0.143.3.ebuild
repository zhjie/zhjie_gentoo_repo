# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta Alsa Host"
HOMEPAGE="https://www.diretta.link/preview/"
X86_VER="2025.02.16"
ARM_VER="2025.01.17"
X86_HOST="diretta-memory-player-${X86_VER}-1-x86_64.pkg.tar.zst"
ARM_HOST="diretta-memory-player-${ARM_VER}-1-aarch64.pkg.tar.xz"
SRC_URI="amd64? ( https://www.audio-linux.com/repo/diretta-memory-player/V3/${X86_HOST} )
         arm64? ( https://www.audio-linux.com/repo_aarch64/${ARM_HOST} )
"

KEYWORDS="~amd64 ~arm64"
SLOT="0"
LICENSE="CDDL"
IUSE=""

src_unpack() {
    if use amd64; then
        _unpacker "${X86_HOST}"
    fi
    if use arm64; then
        _unpacker "${ARM_HOST}"
    fi

    mv ./opt/diretta-memory-player/ "${WORKDIR}/${P}"
}

src_install() {
    insinto "/opt/${PN}/"
    insopts -m755
    doins -r *
    newinitd "${FILESDIR}/diretta-memoryplayer-host.init.d" "diretta-memoryplayer-host"
}
