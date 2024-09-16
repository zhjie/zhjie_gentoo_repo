# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"
IUSE="+naa bmq +bore"

EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
EGIT_BRANCH="rpi-${KV_MAJOR}.${KV_MINOR}.y"
EGIT_COMMIT="191b7e05e5e8db6dcb308220020995fa6885c7ed"

SRC_URI="${GENPATCHES_URI}"

S="${WORKDIR}/linux-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}-raspberrypi"
EXTRAVERSION="-networkaudio"

REQUIRED_USE="
    bore? ( !bmq )
"

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
        eapply "${FILESDIR}"/naa/*.patch
    fi

    # high-hz patch
    eapply "${FILESDIR}/highhz/0001-high-hz-0.patch"
    eapply "${FILESDIR}/highhz/0001-high-hz-1.patch"
    # eapply "${FILESDIR}/highhz/0001-high-hz-2.patch"

    # cachy patch
    # eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
    eapply "${FILESDIR}/cachy/0002-bbr3.patch"
    eapply "${FILESDIR}/cachy/0003-block.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-fixes.patch"
    # eapply "${FILESDIR}/cachy/0006-intel-pstate.patch"
    eapply "${FILESDIR}/cachy/0011-zstd.patch"

    # bmq scheduler
    if use bmq; then
        eapply "${FILESDIR}/bmq/prjc-6.11-r0.patch"
    fi

    # bore scheduler
    if use bore; then
        eapply "${FILESDIR}/bore/0001-bore-cachy.patch"
    fi

    # xanmod patch
    eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
    eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
    eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
    # eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${S}/kernel/Kconfig.hz"

    eapply_user
}
