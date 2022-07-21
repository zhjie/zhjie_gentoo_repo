# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit unpacker user systemd

MY_PN=${PN/-bin/}

DESCRIPTION="Network Audio Daemon"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
    amd64? ( https://www.signalyst.eu/bins/naa/linux/bullseye/${MY_PN}_${PV}-50_amd64.deb )
    arm64? ( https://www.signalyst.eu/bins/naa/linux/bullseye/${MY_PN}_${PV}-50_arm64.deb )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

IUSE="systemd"

RDEPEND=">=media-libs/alsa-lib-1.0.16
	systemd? ( sys-apps/systemd )"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="usr/sbin/networkaudiod"

pkg_setup() {
	if use !systemd; then
		enewgroup networkaudiod
		enewuser networkaudiod -1 -1 "/dev/null" "networkaudiod,audio"
	fi
}

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	mv usr etc lib "${D}" || die
	rm "${D}usr/share/doc/networkaudiod/changelog.Debian.gz"
	if use systemd; then
		systemd_dounit "${FILESDIR}/${MY_PN}.service"
	else
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
}
