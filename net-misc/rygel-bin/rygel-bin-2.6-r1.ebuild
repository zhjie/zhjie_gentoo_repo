# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

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
	dev-libs/glib
	dev-libs/libgee
	net-libs/gssdp:0/1.2-0
	net-libs/gupnp:0/1.2-0
	dev-libs/libunistring
	dev-libs/libxml2
	net-libs/libsoup:2.4
	sys-apps/util-linux
	sys-libs/zlib
	dev-libs/libffi
	dev-libs/libpcre2
	dev-db/sqlite
	net-libs/libpsl
	net-dns/libidn2
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"
QA_PREBUILT="*"

src_unpack() {
	unpack ${FILESDIR}/rygel-bin-${ARCH}-2.6.tar.gz
}

src_install() {
	mv usr etc "${D}" || die
}
