# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta ALSA Host"
HOMEPAGE="https://www.diretta.link/preview/"
ARM_HOST="diretta-alsa-daemon-146_7-1-aarch64.pkg.tar.xz"
SRC_URI="
	https://www.audio-linux.com/repo_aarch64/${ARM_HOST}
"

KEYWORDS="~arm64"
SLOT="0"
LICENSE="CDDL"
IUSE=""

# BDEPEND="|| ( sys-kernel/networkaudio-sources[diretta] sys-kernel/raspberrypi-sources[diretta] )"

src_unpack() {
    _unpacker "${ARM_HOST}"

    mv ./opt/diretta-alsa/ "${WORKDIR}/${P}"
}

src_install() {
    insinto "/opt/${PN}/"
    insopts -m755
    doins -r *
    newinitd "${FILESDIR}/diretta-alsa-host.init.d" "diretta-alsa-host"
}
