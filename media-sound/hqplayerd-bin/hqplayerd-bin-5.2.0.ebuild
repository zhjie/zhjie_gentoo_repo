# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2


EAPI=7

inherit systemd unpacker

MY_PN=${PN/-bin/}
HQV=6

DESCRIPTION="HQPlayer Embedded - upsampling multichannel audio player"
HOMEPAGE="http://www.signalyst.com/consumer.html"
SRC_URI="
amd64? ( !cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/jammy/${MY_PN}_${PV}-${HQV}_amd64.deb ) )
amd64? ( cpu_flags_x86_avx2? ( https://www.signalyst.eu/bins/hqplayerd/jammy/${MY_PN}_${PV}-${HQV}avx2_amd64.deb ) )
arm64? ( https://www.signalyst.eu/bins/hqplayerd/bullseye/${MY_PN}_${PV}-${HQV}_arm64.deb )
"

LICENSE="Signalyst"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="mirror bindist"

IUSE="systemd +upnp cuda cpu_flags_x86_avx2"

RDEPEND=">=dev-libs/glib-2.37.3
	>=media-libs/libgmpris-2.2.1
	>=media-libs/alsa-lib-1.0.16
	>=media-libs/flac-1.3.0
	>=media-libs/libogg-1.3.3
	net-libs/gupnp:0/1.2-0
	net-libs/gssdp:0/1.2-0
	net-libs/gupnp-av
	>=dev-libs/libgee-0.20.2
	net-libs/libsoup:2.4
	x11-libs/cairo
	dev-libs/libusb-compat
	media-sound/mpg123
	media-sound/lame
	>sys-devel/gcc-11.3.0
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

	if use arm64; then
		patchelf --replace-needed libgupnp-1.2.so.0 libgupnp-1.2.so.1 usr/bin/hqplayerd || die
		patchelf --replace-needed libgupnp-av-1.0.so.2 libgupnp-av-1.0.so.3 usr/bin/hqplayerd || die
	fi
}

src_install() {
	mv etc usr var "${D}" || die
	if use amd64; then
		dolib.so opt/hqplayerd/lib/libsgllnx64-2.29.02.so
	fi
	if use arm64; then
		dolib.so opt/hqplayerd/lib/libsglarm64-2.31.0.0.so
	fi
	if use systemd; then
		systemd_dounit "${FILESDIR}/${MY_PN}.service"
	else
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
}
