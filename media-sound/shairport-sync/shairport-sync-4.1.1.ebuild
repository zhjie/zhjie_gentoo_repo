# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE="+alac +soxr convolution systemd ap2"

DEPEND="dev-libs/libdaemon
        dev-libs/libconfig
	dev-libs/openssl
        media-libs/alsa-lib
	alac? ( media-libs/alac )
	soxr? ( media-libs/soxr )
	convolution? ( media-libs/libsndfile )
        systemd? ( sys-apps/systemd )
	ap2? ( app-pda/libplist )
	ap2? ( dev-util/xxd )
	ap2? ( dev-libs/libsodium )
	ap2? ( app-doc/xmltoman )
	ap2? ( net-misc/nqptp )
	ap2? ( media-video/ffmpeg )
"

RDEPEND="${DEPEND}
        net-dns/avahi
"

src_configure() {
	autoreconf -i -f
	econf --sysconfdir=/etc --with-libdaemon --with-ssl=openssl --with-avahi --with-alsa \
		$(use_with soxr) \
		$(use_with alac apple-alac) \
		$(use_with convolution) \
		$(use_with systemd) \
		$(use_with ap2 airplay-2)
}

src_install() {
        emake DESTDIR="${D}" install
        if use systemd ; then
                systemd_dounit "${FILESDIR}"/shairport-sync.service
        else
            	newinitd "${FILESDIR}"/shairport-sync.init.d shairport-sync
        fi
}
