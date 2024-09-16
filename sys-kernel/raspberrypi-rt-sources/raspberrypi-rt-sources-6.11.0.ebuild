# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="527537f7c4bd62d349f33ba63e9e6332f40ff173"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"
K_EXP_GENPATCHES_NOUSE="1"

RT_VERSION="rc5-rt5"
MINOR_VERSION="0"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"
IUSE="+naa"

inherit kernel-2 git-r3
detect_version
EXTRAVERSION="-networkaudio-rt${RT_VERSION}"

# RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}-${RT_VERSION}.tar.xz
RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/${RT_PATCH}"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI} ${RT_URI}"

S="${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt"

src_unpack() {
    git-r3_src_unpack
    mv "${WORKDIR}/${PF}" "${S}"

    unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
    unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz

    rm -rfv "${WORKDIR}"/10*.patch
    rm -rfv "${S}/.git"
    mkdir "${WORKDIR}"/genpatch
    mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/

    unpack patches-${K_BASE_VER}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
    # unpack patches-${K_BASE_VER}-${RT_VERSION}.tar.xz

    mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch
    echo "${EXTRAVERSION}"
    unpack_set_extraversion
}

src_prepare() {
    local p rt_patches=(
    )

    for p in "${rt_patches[@]}"; do
        eapply "${WORKDIR}/rtpatch/${p}"
    done

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

    # xanmod patch
    eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
    eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
    eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
    # eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt/kernel/Kconfig.hz"
    eapply_user
}
