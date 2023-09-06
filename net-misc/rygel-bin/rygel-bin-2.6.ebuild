# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit unpacker systemd

MY_PN=${PN/-bin/}
VN="55"

DESCRIPTION="Network Audio Daemon"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI=""

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

IUSE=""

RDEPEND="
	x11-libs/gdk-pixbuf
	dev-libs/libunistring
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="*"

src_unpack() {
	unpack ${FILESDIR}/rygel-bin-${ARCH}-2.6.tar.tbz
}

src_install() {
	mv usr etc "${D}" || die
}
