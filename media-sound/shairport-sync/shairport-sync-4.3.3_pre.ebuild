# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/refs/tags/4.3.3-dev.tar.gz -> ${P}.tar.gz"

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
	ap2? ( dev-util/xxd )
	ap2? ( app-pda/libplist )
	ap2? ( dev-libs/libsodium )
	ap2? ( media-video/ffmpeg )
	ap2? ( net-misc/nqptp )
	ap2? ( dev-libs/libgcrypt )
	ap2? ( net-dns/avahi )
"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
        mv ${WORKDIR}/shairport-sync-4.3.3-dev ${WORKDIR}/${P}
}

src_configure() {
	autoreconf -i -f

        local myeconfargs=(
		--sysconfdir=/etc
		--with-libdaemon
		--with-ssl=openssl
		--with-alsa
		$(use_with soxr)
		$(use_with alac apple-alac)
		$(use_with convolution)
		$(use_with systemd)
        )

	if use ap2 ; then
		myeconfargs+=( --with-airplay-2 )
		myeconfargs+=( --with-avahi )
	else
		myeconfargs+=( --with-tinysvcmdns )
	fi

        econf "${myeconfargs[@]}"
}

src_install() {
        emake DESTDIR="${D}" install
        if use systemd ; then
                systemd_dounit "${FILESDIR}"/shairport-sync.service
        else
		newinitd "${FILESDIR}"/shairport-sync.init.d shairport-sync
        fi
}
