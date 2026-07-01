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

IUSE="systemd cpu_flags_x86_avx2"

RDEPEND="
        >=media-libs/alsa-lib-1.0.16
        x11-libs/cairo
        net-libs/libmicrohttpd
        media-sound/lame
        media-sound/mpg123-base
        >=media-libs/libogg-1.3.3
        llvm-runtimes/openmp
        dev-libs/libusb-compat
"

DEPEND="${RDEPEND}
        >=dev-util/patchelf-0.10
"

S="${WORKDIR}"
QA_PREBUILT="*"

src_prepare() {
	rm -rf usr/lib
	rm -rf usr/share/doc/hqplayerd
        mkdir -p var/lib/hqplayer/home
        touch var/lib/hqplayer/home/.keep

	default

	patchelf --replace-needed libomp.so.5 libomp.so usr/bin/hqplayerd    || die
	patchelf --replace-needed libxml2.so.2 libxml2.so.16 usr/bin/hqplayerd || die
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
