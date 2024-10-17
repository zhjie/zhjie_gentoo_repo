# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="4"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa bmq +bore"
REQUIRED_USE="
    bmq? ( !bore )
    bore? ( !bmq )
"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
    UNIPATCH_LIST_DEFAULT=""
    UNIPATCH_EXCLUDE=""
    kernel-2_src_unpack
}

src_prepare() {
    # naa patch
    if use naa; then
        eapply "${FILESDIR}"/naa/*.patch
    fi

    # cachy patch
    eapply "${FILESDIR}/cachy/0001-address-masking.patch"
    eapply "${FILESDIR}/cachy/0002-amd-cache-optimzer.patch"
    eapply "${FILESDIR}/cachy/0003-bbr3.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-fixes.patch"
    eapply "${FILESDIR}/cachy/0006-intel-pstate.patch"
    eapply "${FILESDIR}/cachy/0009-perf-per-core.patch"
    eapply "${FILESDIR}/cachy/0011-thp-shrinker.patch"
    eapply "${FILESDIR}/cachy/0012-zstd.patch"

    # highhz patch
    eapply "${FILESDIR}"/highhz/*.patch

    # bmq scheduler
    if use bmq; then
        eapply "${FILESDIR}/bmq/prjc-6.11-r1.patch"
    fi

    # bore scheduler
    if use bore; then
        eapply "${FILESDIR}/bore/0001-bore-cachy.patch"
    fi

    # cloudflare patch
    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    eapply_user
}
