# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

DESCRIPTION="music player"
HOMEPAGE="https://roonlabs.com/index.html"
SRC_URI="
    amd64? ( http://download.roonlabs.com/builds/RoonBridge_linuxx64.tar.bz2 -> ${PF}_x64.tar.bz2 )
    arm64? ( http://download.roonlabs.com/builds/RoonBridge_linuxarmv8.tar.bz2 -> ${PF}_armv8.tar.bz2 )
"

LICENSE="roonlabs"

SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="mirror bindist"

IUSE="+rt"

RDEPEND=">=media-libs/alsa-lib-1.0.27"

DEPEND="${RDEPEND}"


S="${WORKDIR}"
MY_PN=RoonBridge

QA_PREBUILT="*"

src_prepare() {
    default
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RoonBridge        || die
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RoonBridgeHelper  || die
    sed -i 's/\-\-debug//g' "${S}"/RoonBridge/Bridge/RAATServer        || die
    rm -rf "${S}"/RoonBridge/RoonMono/etc/mono/2.0                       || die
    rm -rf "${S}"/RoonBridge/RoonMono/lib/mono/2.0                       || die
}

src_install() {
    insinto "/opt/${PN}/"
    insopts -m755
    doins -r RoonBridge/*
    if use rt; then
        newinitd "${FILESDIR}/roonbridge.init.d.rt" "roonbridge"
    else
        newinitd "${FILESDIR}/roonbridge.init.d" "roonbridge"
    fi
}
