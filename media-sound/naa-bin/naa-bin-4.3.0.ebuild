# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit unpacker systemd

MY_PN=${PN/-bin/}
VN="55"

DESCRIPTION="Network Audio Daemon"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
    amd64? ( https://www.signalyst.eu/bins/naa/linux/bullseye/networkaudiod_${PV}-${VN}_amd64.deb )
    arm64? ( https://www.signalyst.eu/bins/naa/linux/bullseye/networkaudiod_${PV}-${VN}_arm64.deb )
    arm? ( https://www.signalyst.eu/bins/naa/linux/bullseye/networkaudiod_${PV}-${VN}_arm64.deb )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
RESTRICT="mirror bindist"

IUSE="systemd +rt"

RDEPEND=">=media-libs/alsa-lib-1.0.16
	systemd? ( sys-apps/systemd )
	!media-sound/networkaudiod-bin
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="usr/sbin/networkaudiod"

#pkg_setup() {
#	if use !systemd; then
#		enewgroup networkaudiod
#		enewuser networkaudiod -1 -1 "/dev/null" "networkaudiod,audio"
#	fi
#}

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