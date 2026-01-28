# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker
MY_PV=$(ver_rs 1 '_')

DESCRIPTION="Linux Diretta ALSA Host"
HOMEPAGE="https://www.diretta.link/preview/"
ARM_HOST="diretta-alsa-daemon-${MY_PV}-1-aarch64.pkg.tar.xz"
X86_HOST="diretta-alsa-daemon-${MY_PV}-1-x86_64.pkg.tar.zst"

SRC_URI="
	arm64? ( https://www.audio-linux.com/repo_aarch64/${ARM_HOST} )
	amd64? ( https://www.audio-linux.com/ftp/temp/diretta_v2/${X86_HOST} )
"

KEYWORDS="arm64 amd64"
SLOT="0"
LICENSE="CDDL"
IUSE=""

src_unpack() {
    unpacker_src_unpack

    mv opt/diretta-alsa/ "${WORKDIR}/${P}"
}

src_install() {
    insinto "/opt/${PN}/"
    insopts -m755
    doins -r *
    newinitd "${FILESDIR}/diretta-alsa-host.init.d" "diretta-alsa-host"
}
