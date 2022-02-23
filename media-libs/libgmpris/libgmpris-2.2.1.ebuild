# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit unpacker user

MY_PN=${PN/}

DESCRIPTION="libgmpris"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
	amd64? ( https://www.sonarnerd.net/src/buster/${MY_PN}_${PV}-7_amd64.deb )
	arm64?   ( https://www.sonarnerd.net/src/buster/${MY_PN}_${PV}-7_arm64.deb )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror bindist"


RDEPEND=">=dev-libs/glib-2.37.3
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"


src_unpack() {
	unpack_deb ${A}
}

#src_prepare () {
#(cp usr/lib/x86_64-linux-gnu/libgmpris.so.0.0.0 usr/lib/)
#(chmod +x usr/lib/libgmpris.so.0.0.0)
#(rm -r usr/lib/x86_64-linux-gnu/)
#eapply_user
#}

src_prepare () {
if use amd64 ; then
	(cp usr/lib/x86_64-linux-gnu/libgmpris.so.0.0.0 usr/lib/)
	(mv usr/lib/ usr/lib64/)
	(chmod +x usr/lib64/libgmpris.so.0.0.0)
	(rm -r usr/lib64/x86_64-linux-gnu/)
	eapply_user
elif use arm64 ; then
	(cp usr/lib/aarch64-linux-gnu/libgmpris.so.0.0.0 usr/lib/)
	(mv usr/lib/ usr/lib64/)
	(chmod +x usr/lib64/libgmpris.so.0.0.0)
	(rm -r usr/lib64/aarch64-linux-gnu/)
	eapply_user
fi
}

#src_install() {
#	mv usr/lib/x86_64-linux-gnu/* /usr/lib64/ "${D}" || die
#	mv usr/share/doc/* /usr/share/doc/
#	rm /usr/share/doc/libgmpris/changelog.gz
#}


#src_install() {
#	mv usr "${D}" || die
#	rm "${D}usr/share/doc/libgmpris/changelog.gz"
#	dosym /usr/lib/libgmpris.so.0.0.0 /usr/lib/libgmpris.so.0
#}

src_install() {
        mv usr "${D}" || die
        rm "${D}usr/share/doc/libgmpris/changelog.gz"
        dosym /usr/lib64/libgmpris.so.0.0.0 /usr/lib64/libgmpris.so.0
}

#pkg_postinst() {
#	ls -n /usr/lib64/libgmpris.so.0.0.0 /usr/lib64/libgmpris.so.0
#	ls -n /usr/lib/libgmpris.so.0.0.0 /usr/lib/libgmpris.so.0
#}
