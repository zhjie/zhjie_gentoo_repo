# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="20"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"
IUSE="naa bmq diretta highhz"

EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
EGIT_BRANCH="rpi-${KV_MAJOR}.${KV_MINOR}.y"

SRC_URI="${GENPATCHES_URI}"

S="${WORKDIR}/linux-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}-raspberrypi"
EXTRAVERSION="-networkaudio"

src_unpack() {
    git-r3_src_unpack
    mv "${WORKDIR}/${PF}" "${S}"

    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.base.tar.xz
    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.extras.tar.xz

    rm -rfv "${WORKDIR}"/10*.patch
    rm -rfv "${S}/.git"

    mkdir "${WORKDIR}"/genpatch
    mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/
    unpack_set_extraversion
}

src_prepare() {
    # genpatch
    eapply "${WORKDIR}"/genpatch/*.patch

    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0002-Lynx-Hilo-quirk.patch"
        eapply "${FILESDIR}/naa/0003-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0004-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0005-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
        eapply "${FILESDIR}/naa/0009-DSD-patches-unstaged.patch"
    fi

    eapply "${FILESDIR}/cachy/0002-bbr3.patch"
    eapply "${FILESDIR}/cachy/0003-cachy.patch"
    eapply "${FILESDIR}/cachy/0004-fixes.patch"
    eapply "${FILESDIR}/cachy/0008-zstd.patch"

    # highhz patch
    if use highhz; then
        eapply "${FILESDIR}/highhz/0001-high-hz-0.patch"
        eapply "${FILESDIR}/highhz/0001-high-hz-1.patch"
        eapply "${FILESDIR}/highhz/0001-high-hz-2.patch"
    fi

    # bmq scheduler
    if use bmq; then
        eapply "${FILESDIR}/bmq/5020_BMQ-and-PDS-io-scheduler-v6.12-r0.patch"
    fi

    # diretta alsa host driver
    if use diretta; then
        eapply "${FILESDIR}/diretta/diretta_alsa_host.patch"
        eapply "${FILESDIR}/diretta/diretta_alsa_host_2025.02.16.patch"
    fi

    # cloudflare patch
    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
    eapply_user
}
