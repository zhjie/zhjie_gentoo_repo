# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/4.2.1d0.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE="+alac +soxr convolution systemd ap2 avahi tinysvcmdns"

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
        avahi? ( net-dns/avahi )
	tinysvcmdns? ( net-dns/tinysvcmdns )
"

src_unpack() {
	unpack ${P}.tar.gz
        mv ${WORKDIR}/shairport-sync-4.2.1d0 ${WORKDIR}/${P}
}

src_configure() {
	autoreconf -i -f
	econf --sysconfdir=/etc --with-libdaemon --with-ssl=openssl --with-alsa --with-tinysvcmdns \
		$(use_with avahi) \
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
