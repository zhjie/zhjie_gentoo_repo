# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils user git-r3

MY_PN="shairport-sync"

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
EGIT_REPO_URI="https://github.com/mikebrady/shairport-sync.git"
EGIT_BRANCH="development"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
# KEYWORDS=""
IUSE="convolution airplay-2 soxr alac"

DEPEND="media-libs/alsa-lib
	dev-libs/openssl
	dev-libs/libconfig
	dev-libs/libdaemon
	alac? ( media-libs/alac )
        soxr? ( media-libs/soxr )
	convolution? ( media-libs/libsndfile )
	airplay-2? ( app-pda/libplist )
	airplay-2? ( dev-util/xxd )
	airplay-2? ( dev-libs/libsodium )
	airplay-2? ( app-doc/xmltoman )
	airplay-2? ( net-misc/nqptp )"
RDEPEND="${DEPEND}
	net-dns/avahi"

#S="${WORKDIR}/${MY_PN}"

pkg_setup() {
	enewuser shairport-sync -1 -1 -1 audio
}

src_configure() {
	autoreconf -i -f
	econf \
		--with-alsa --with-avahi --with-ssl=openssl --with-libdaemon
		$(use_with soxr) \
		$(use_with alac apple-alac) \
		$(use_with convolution) \
		$(use_with airplay-2)
}

src_install() {
	emake DESTDIR="${D}" install
	if use airplay-2; then
		newinitd "${FILESDIR}"/${MY_PN}-ap2.initd ${MY_PN}
	else
	  newinitd "${FILESDIR}"/${MY_PN}.initd ${MY_PN}
	fi
}
