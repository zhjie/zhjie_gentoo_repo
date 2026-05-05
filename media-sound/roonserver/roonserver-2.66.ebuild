# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8
inherit systemd

DESCRIPTION="THE ULTIMATE MUSIC PLAYER FOR MUSIC FANATICS"
HOMEPAGE="https://roonlabs.com"
SRC_URI="https://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2 -> ${PF}.tar.bz2"

LICENSE="roonlabs"

SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror bindist"

IUSE="systemd samba ffmpeg web alsa +server-gc taskset4 rt trace mp3"

RDEPEND="dev-libs/icu
    alsa? ( media-libs/alsa-lib )
    samba? ( net-fs/cifs-utils )
    samba? ( dev-libs/libtasn1 )
    ffmpeg? ( media-video/ffmpeg )
    trace? ( dev-util/lttng-ust )
    mp3? ( media-video/ffmpeg[mp3] )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {

    default

    if ! use samba; then
        rm -vrf "${S}"/RoonServer/Appliance/roon_smb_watcher || die
    fi

    if ! use web; then
        rm -vrf "${S}"/RoonServer/*/*.otf || die
        rm -vrf "${S}"/RoonServer/*/*.ttf || die
        rm -vrf "${S}"/RoonServer/Appliance/webroot || die
    fi

    if use server-gc; then
	eapply "${FILESDIR}/runtimeconfig.patch"
    fi

    if use taskset4; then
        eapply "${FILESDIR}/taskset4.patch"
    fi

    if ! use trace; then
        rm -vrf "${S}"/RoonServer/RoonDotnet/shared/Microsoft.NETCore.App/*/libcoreclrtraceptprovider.so || die
    fi
}

src_install() {
    insinto "/opt/${PN}/"
    insopts -m755
    doins -r RoonServer/*
    if use systemd; then
        systemd_dounit "${FILESDIR}/roonserver.service"
    elif use rt; then
        newinitd "${FILESDIR}/roonserver.init.d.rt" "roonserver"
    else
        newinitd "${FILESDIR}/roonserver.init.d" "roonserver"
    fi
}
