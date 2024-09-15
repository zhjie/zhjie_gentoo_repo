# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd unpacker

MY_PN=${PN/-bin/}
HQV=22

DESCRIPTION="HQPlayer Embedded - upsampling multichannel audio player"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
amd64? ( !cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/noble/${MY_PN}_${PV}-${HQV}intel_amd64.deb ) )
amd64? ( cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/noble/${MY_PN}_${PV}-${HQV}_amd64.deb ) )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror bindist"

IUSE="systemd +upnp cuda cpu_flags_x86_avx2"

RDEPEND=">=dev-libs/glib-2.37.3
	>=media-libs/libgmpris-2.2.1
	>=media-libs/alsa-lib-1.0.16
	>=media-libs/flac-1.3.0
	>=media-libs/libogg-1.3.3
	net-libs/gupnp:1.6
	net-libs/gssdp:1.6
	net-libs/gupnp-av
	>=dev-libs/libgee-0.20.2
	net-libs/libsoup:3.0
	x11-libs/cairo
	dev-libs/libusb-compat
	media-sound/mpg123-base
	media-sound/lame
	sys-libs/libomp
	upnp? ( || ( net-misc/rygel-bin net-misc/rygel ) )
	cuda? ( dev-util/nvidia-cuda-toolkit )
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
