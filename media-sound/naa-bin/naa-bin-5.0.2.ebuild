# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit unpacker systemd

MY_PN=${PN/-bin/}
VN="61"

DESCRIPTION="Network Audio Daemon"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
    amd64? ( https://www.signalyst.eu/bins/naa/linux/bookworm/networkaudiod_${PV}-${VN}_amd64.deb )
    arm64? ( https://www.signalyst.eu/bins/naa/linux/bookworm/networkaudiod_${PV}-${VN}_arm64.deb )
    arm? ( https://www.signalyst.eu/bins/naa/linux/bookworm/networkaudiod_${PV}-${VN}_armhf.deb )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="amd64 arm arm64"
RESTRICT="mirror bindist"

IUSE="systemd +rt"

RDEPEND=">=media-libs/alsa-lib-1.0.16
	systemd? ( sys-apps/systemd )
	!media-sound/networkaudiod-bin
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="usr/sbin/networkaudiod"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	mv usr etc lib "${D}" || die
	rm -rf  "${D}usr/share/doc/networkaudiod/"
	if use systemd; then
		systemd_dounit "${FILESDIR}/${MY_PN}.service"
	elif use rt; then
		newinitd "${FILESDIR}/${MY_PN}.init.d.rt" "${MY_PN}"
	else
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
}
