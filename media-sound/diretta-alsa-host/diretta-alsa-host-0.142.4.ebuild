# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta Alsa Host"
HOMEPAGE="https://www.diretta.link/preview/"

DIRETTA_ALSA_HOST="diretta-alsa-daemon-2024.11.09-1-x86_64.pkg.tar.zst"
SRC_URI="https://www.audio-linux.com/repo/${DIRETTA_ALSA_HOST}"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="CDDL"
IUSE=""

BDEPEND="sys-kernel/networkaudio-sources[diretta]"

src_unpack() {
        _unpacker "${DIRETTA_ALSA_HOST}"
	mkdir -p "${WORKDIR}"/"${P}"/opt
	mv opt/diretta-alsa "${WORKDIR}"/"${P}"/"${PN}"
}

src_install() {
	insinto "/opt/"
	insopts -m755
	doins -r *
	newinitd "${FILESDIR}/diretta-alsa-host.init.d" "diretta-alsa-host"
}
