# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE=""

RDEPEND="media-libs/alsa-lib
        net-dns/avahi
        dev-libs/libdaemon
        dev-libs/libconfig
	dev-libs/openssl
	media-libs/alac
"

RDEPEND="${DEPEND}
	media-libs/alsa-lib
	net-dns/avahi
	media-libs/alac
"

src_configure() {
	autoreconf -i -f
	econf -with-alsa --with-avahi --with-libdaemon --with-ssl=openssl --with-apple-alac
}

src_install() {
	emake DESTDIR="${D}" install
	newinitd "${FILESDIR}"/${MY_PN}.initd ${MY_PN}
}
