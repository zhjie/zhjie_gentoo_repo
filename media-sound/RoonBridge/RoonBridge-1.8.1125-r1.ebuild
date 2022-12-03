# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit systemd


DESCRIPTION="music player"
HOMEPAGE="https://roonlabs.com/index.html"
SRC_URI="
  amd64? ( http://download.roonlabs.com/builds/RoonBridge_linuxx64.tar.bz2 -> ${P}_x64.tar.bz2 )
  arm64? ( http://download.roonlabs.com/builds/RoonBridge_linuxarmv8.tar.bz2 -> ${P}_armv8.tar.bz2 )
  arm?   ( http://download.roonlabs.com/builds/RoonBridge_linuxarmv7hf.tar.bz2 -> ${P}_armv7hf.tar.bz2 )
"

LICENSE="roonlabs"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~arm"
RESTRICT="mirror bindist"

IUSE="systemd debug +rt system-mono"

RDEPEND=">=media-libs/alsa-lib-1.0.27
         system-mono? ( dev-lang/mono )"

DEPEND="${RDEPEND}"


S="${WORKDIR}"
MY_PN=RoonBridge

QA_PREBUILT="*"

src_prepare() {
  default
  if ! use debug; then
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RoonBridge        || die
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RoonBridgeHelper  || die
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RAATServer        || die
  fi
  rm -rf "${S}"/RoonBridge/RoonMono/etc/mono/2.0                       || die
  rm -rf "${S}"/RoonBridge/RoonMono/lib/mono/2.0                       || die
  if use system-mono; then
    # rm -rf "${S}"/RoonBridge/RoonMono/*                                || die
    mv "${S}"/RoonBridge/RoonMono/  "${S}"/RoonBridge/RoonMono.bkp     || die
    mkdir -p "${S}"/RoonBridge/RoonMono/bin                            || die
    ln -sf /usr/bin/mono-sgen "${S}"/RoonBridge/RoonMono/bin/mono-sgen || die    
  fi
}

src_install() {
  insinto "/opt/${PN}/"
  insopts -m755
  doins -r RoonBridge/*
  if use systemd; then
      systemd_dounit "${FILESDIR}/roonbridge.service"
  elif use rt; then
      newinitd "${FILESDIR}/roonbridge.init.d.rt" "roonbridge"
  else
      newinitd "${FILESDIR}/roonbridge.init.d" "roonbridge"
  fi
}

