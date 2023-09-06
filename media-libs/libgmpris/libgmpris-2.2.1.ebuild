# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit autotools

MY_PN=${PN/}

DESCRIPTION="libgmpris"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
	https://www.sonarnerd.net/src/focal/src/libgmpris_2.2.1-8.tar.gz
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror bindist"


RDEPEND=">=dev-libs/glib-2.37.3
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
	default
	mv "${S}"/libgmpris/* "${S}"/
	eautoconf
}

#src_configure() {
#	econf
#}

src_install() {
	dolib.so "${S}"/src/.libs/libgmpris.so.0.0.0
	dosym /usr/lib64/libgmpris.so.0.0.0 /usr/lib64/libgmpris.so.0
}
