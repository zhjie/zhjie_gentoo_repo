# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils user

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE="+alsa pulseaudio jack soundio soxr +alac convolution systemd"

DEPEND="dev-libs/libdaemon
        dev-libs/libconfig
	dev-libs/openssl
        alsa? ( media-libs/alsa-lib )
        pulseaudio? ( media-sound/pulseaudio )
        jack? ( virtual/jack )
        soundio? ( media-libs/libsoundio )
	soxr? ( media-libs/soxr )
	alac? ( media-libs/alac )
	convolution? ( media-libs/libsndfile )
        systemd? ( sys-apps/systemd )
"

RDEPEND="${DEPEND}
        net-dns/avahi"

pkg_setup() {
        enewuser shairport-sync -1 -1 -1 audio
}

src_configure() {
	autoreconf -i -f
	econf --with-libdaemon --with-ssl=openssl --with-avahi \
		$(use_with alsa) \
                $(use_with pulseaudio pa) \
		$(use_with jack) \
		$(use_with soundio) \
		$(use_with soxr) \
		$(use_with alac apple-alac) \
		$(use_with convolution) \
                $(use_with systemd)
}

src_install() {
	emake DESTDIR="${D}" install
        if use systemd ; then
		systemd_dounit "${FILESDIR}"/shairport-sync.service
        else
		newinitd "${FILESDIR}"/shairport-sync.initd shairport-sync
	fi
}
