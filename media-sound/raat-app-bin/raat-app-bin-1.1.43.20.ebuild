# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit unpacker systemd

DESCRIPTION="raat app"
HOMEPAGE="http://www.roon.app"
SRC_URI="
    arm64? ( https://debianrepo.hifiberry.com/pool/trixie/main/h/hifiberry-raat/hifiberry-raat_${PVR}_arm64.deb )
"

LICENSE="Roon Labs LLC"
SLOT="0"
KEYWORDS="arm64"
RESTRICT="mirror bindist"

IUSE="systemd"

RDEPEND=">=media-libs/alsa-lib-1.0.16
        dev-libs/glib
	systemd? ( sys-apps/systemd )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="
	usr/bin/raat_app
	usr/bin/luai
	usr/bin/luac
	usr/bin/raat_null_sample
	usr/bin/raatool
"

src_unpack() {
	unpack_deb hifiberry-raat_${PVR}_arm64.deb
}

src_install() {
	rm -rf usr/share
	rm -rf usr/lib
	mv usr "${D}" || die
	if use systemd; then
		systemd_dounit "${FILESDIR}/raat.service"
	else
		newinitd "${FILESDIR}/raat.init.d" "raat"
	fi
}
