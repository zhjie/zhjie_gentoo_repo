# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd unpacker

MY_PN=${PN/-bin/}
MY_PV=$(ver_cut 1-3)-$(ver_cut 4)

DESCRIPTION="HQPlayer Embedded - Embedded version of HQPlayer is designed for building Linux-based music playback devices and digital audio processors"
HOMEPAGE="https://signalyst.com/hqplayer-embedded"
SRC_URI="
	amd64? ( !cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/noble/${MY_PN}_${MY_PV}intel_amd64.deb ) )
	amd64? ( cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/noble/${MY_PN}_${MY_PV}_amd64.deb ) )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror bindist"

IUSE="systemd +upnp +rygen-bin cpu_flags_x86_avx2"

RDEPEND=">=dev-libs/glib-2.80.0
	>=media-libs/libgmpris-2.2.1
	>=media-libs/alsa-lib-1.0.16
	>=media-libs/flac-1.3.0
	>=media-libs/libogg-1.3.3
	net-libs/gupnp:1.6
	net-libs/gssdp
	net-libs/gupnp-av
	>=dev-libs/libgee-0.20.2
	net-libs/libsoup:3.0
        x11-libs/cairo
	dev-libs/libusb-compat
	media-sound/mpg123-base
	media-sound/lame
	llvm-runtimes/openmp
	upnp? ( rygen-bin? ( net-misc/rygel-bin !net-misc/rygel ) )
	upnp? ( !rygen-bin? ( !net-misc/rygel-bin net-misc/rygel ) )
"

DEPEND="${RDEPEND}
        >=dev-util/patchelf-0.10
"

S="${WORKDIR}"
QA_PREBUILT="*"

src_prepare() {
	rm -rf usr/lib
	rm -rf usr/share/doc/hqplayerd/

	default

	patchelf --replace-needed libomp.so.5 libomp.so usr/bin/hqplayerd || die

	if ! use upnp; then
		patchelf --remove-needed librygel-renderer-2.6.so.2 usr/bin/hqplayerd || die
		patchelf --remove-needed librygel-core-2.6.so.2     usr/bin/hqplayerd || die
	fi
}

src_install() {
	mv etc usr var "${D}" || die
	if use amd64; then
		dolib.so opt/hqplayerd/lib/libsgllnx64-2.29.02.so
	fi
	if use systemd; then
		systemd_dounit "${FILESDIR}/${MY_PN}.service"
	else
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
}
