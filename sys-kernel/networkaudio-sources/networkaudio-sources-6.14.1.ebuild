# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="2"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="~amd64"
IUSE="naa t2 bore diretta amd highhz"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
    UNIPATCH_LIST_DEFAULT=""
    UNIPATCH_EXCLUDE=""
    kernel-2_src_unpack
}

src_prepare() {
    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0001-Miscellaneous-sample-rate-extensions.patch"
        eapply "${FILESDIR}/naa/0002-Lynx-Hilo-quirk.patch"
        eapply "${FILESDIR}/naa/0003-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0004-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0005-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
        eapply "${FILESDIR}/naa/0009-DSD-patches-unstaged.patch"
    fi

    # cachy patch
    if use amd; then
        eapply "${FILESDIR}/cachy/6.14/0001-amd-pstate.patch"
        eapply "${FILESDIR}/cachy/6.14/0002-amd-tlb-broadcast.patch"
    fi

    eapply "${FILESDIR}/cachy/6.14/0004-bbr3.patch"
    eapply "${FILESDIR}/cachy/6.14/0005-cachy.patch"
    eapply "${FILESDIR}/cachy/6.14/0006-crypto.patch"
    eapply "${FILESDIR}/cachy/6.14/0007-fixes.patch"
    eapply "${FILESDIR}/cachy/6.14/0010-zstd.patch"

    # apple t2 patch
    if use t2; then
        eapply "${FILESDIR}/cachy/6.14/0009-t2.patch"
    fi

    # bore scheduler
    if use bore; then
        eapply "${FILESDIR}/cachy/6.14/sched/0001-bore-cachy.patch"
    fi

    # highhz patch
    if use highhz; then
        eapply "${FILESDIR}/highhz/0001-high-hz-0.patch"
        eapply "${FILESDIR}/highhz/0001-high-hz-1.patch"
        eapply "${FILESDIR}/highhz/0001-high-hz-2.patch"
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
