# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2


EAPI=7

inherit systemd unpacker

MY_PN=${PN/-bin/}

DESCRIPTION="HQPlayer Embedded - upsampling multichannel audio player"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
amd64? ( !cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/jammy/${MY_PN}_${PV}-1_amd64.deb ) )
amd64? ( cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/jammy/${MY_PN}_${PV}-2avx2_amd64.deb ) )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

IUSE="systemd cpu_flags_x86_avx2"

RDEPEND=">=dev-libs/glib-2.37.3
	>=media-libs/libgmpris-2.2.1
	>=media-libs/alsa-lib-1.0.16
	>=media-libs/flac-1.3.0
	>=media-libs/libogg-1.3.3
	>=sys-libs/libomp-7.1.0
	>=net-libs/gupnp-1.0.4
	>=net-libs/gupnp-av-0.12.11
	>=dev-libs/libgee-0.20.2
	>=dev-util/patchelf-0.10
	>=net-libs/libsoup-2.62.3
	>=media-sound/wavpack-5.3.2-r1
	!>net-libs/gssdp-1.6
	!>net-libs/gupnp-1.6
	x11-libs/cairo
	dev-libs/libusb-compat
	media-sound/mpg123
	media-sound/lame
	>sys-devel/gcc-11.3.0"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
	rm -rf usr/lib
	rm -rf usr/share/doc/hqplayerd/changelog.Debian.gz

	default
	 if use cpu_flags_x86_avx2 ; then
		 patchelf --replace-needed libomp.so.5 libomp.so usr/bin/hqplayerd || die
	 fi
	 #patchelf --replace-needed libgupnp-1.2.so.0 libgupnp-1.2.so.1 usr/bin/hqplayerd || die
 	 #patchelf --replace-needed libgupnp-av-1.0.so.2 libgupnp-av-1.0.so.3 usr/bin/hqplayerd || die
}

src_install() {
	mv etc usr var "${D}" || die
	dolib.so opt/hqplayerd/lib/libsgllnx64-2.29.02.so
	if use systemd; then
		systemd_dounit "${FILESDIR}/${MY_PN}.service"
	else
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
}
