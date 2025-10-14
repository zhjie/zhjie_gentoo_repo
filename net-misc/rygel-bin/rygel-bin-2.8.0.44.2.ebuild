# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit unpacker systemd

MY_PN=${PN/-bin/}

DESCRIPTION="Network Audio Daemon"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI=""

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror bindist"

IUSE=""

RDEPEND="
	dev-libs/glib
	dev-libs/libgee
	net-libs/gssdp
	net-libs/gupnp
	dev-libs/libxml2
	net-libs/libsoup
	sys-libs/zlib
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="*"

src_unpack() {
	unpack ${FILESDIR}/rygel-bin-amd64-2.8.0.44.2.tar.gz
}

src_install() {
	mv usr "${D}" || die
}
