# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils user git-r3

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
EGIT_REPO_URI="https://github.com/mikebrady/shairport-sync.git"
EGIT_BRANCH="development"
EGIT_MIN_CLONE_TYPE="shallow"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE="+alsa pulseaudio jack soundio soxr +alac convolution systemd +ap2"

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
        ap2? ( media-sound/nqptp )
        ap2? ( app-pda/libplist )
	ap2? ( dev-libs/libsodium )
	ap2? ( dev-libs/libgcrypt )
	ap2? ( media-video/ffmpeg )
	ap2? ( dev-util/xxd )
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
                $(use_with systemd) \
                $(use_with ap2 airplay-2)
}

src_install() {
	emake DESTDIR="${D}" install
        if use systemd ; then
		systemd_dounit "${FILESDIR}"/shairport-sync.service
        elif use ap2 ; then
		newinitd "${FILESDIR}"/shairport-sync-ap2.initd shairport-sync
        else
		newinitd "${FILESDIR}"/shairport-sync.initd shairport-sync
	fi
}
