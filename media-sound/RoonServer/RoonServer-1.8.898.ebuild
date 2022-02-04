# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit systemd


DESCRIPTION="music player sever"
HOMEPAGE="https://roonlabs.com/index.html"
SRC_URI="http://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2  -> ${P}.tar.bz2"

LICENSE="roonlabs"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

IUSE="+systemd ffmpeg +system-dotnet embedded-fonts"

RDEPEND="dev-libs/icu
	 >=media-libs/alsa-lib-1.0.29
	 ffmpeg? ( media-video/ffmpeg )
         system-dotnet? ( || ( dev-dotnet/dotnet-sdk-bin dev-dotnet/dotnet-runtime ) )
"

DEPEND="${RDEPEND}"


S="${WORKDIR}"

src_prepare() {
  default
  if use system-dotnet; then
    rm -vrf "${S}"/RoonServer/RoonDotnet/* || die
    ln -sf /usr/bin/dotnet "${S}"/RoonServer/RoonDotnet/dotnet || die
  fi
  if ! use embedded-fonts; then
    rm -vrf "${S}"/RoonServer/Appliance/*.otf || die
    rm -vrf "${S}"/RoonServer/Appliance/*.ttf || die
  fi
}

src_install() {
  insinto "/opt/${PN}/"
  insopts -m755
  doins -r RoonServer/*
  if use systemd; then
    systemd_dounit "${FILESDIR}/roonserver.service"
  else
    newinitd "${FILESDIR}/roonserver.init.d" "roonserver"
  fi
}
