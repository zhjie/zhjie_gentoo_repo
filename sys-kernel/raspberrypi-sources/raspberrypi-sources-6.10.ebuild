# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.10"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="1e607cf22bff1b2949b2e8284d5635cdcac18edc"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="4"
K_EXP_GENPATCHES_NOUSE="1"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
inherit kernel-2 git-r3
detect_version
EXTRAVERSION="-networkaudio"

DESCRIPTION="The very latest -git version of the Linux kernel with Gentoo patchset and naa patches"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod bmq +bore"
REQUIRED_USE="
        bore? ( !bmq )
"

RDEPEND=""
DEPEND="${RDEPEND}
    >=sys-devel/patch-2.7.6-r4"

src_unpack() {
    git-r3_src_unpack
    mv "${WORKDIR}/${PF}" "${S}"

    unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
    unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz

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
    if use cachy; then
        eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
        eapply "${FILESDIR}/cachy/0002-bbr3.patch"
        eapply "${FILESDIR}/cachy/0003-block.patch"
        eapply "${FILESDIR}/cachy/0004-cachy.patch"
        eapply "${FILESDIR}/cachy/0005-crypto.patch"
        eapply "${FILESDIR}/cachy/0006-fixes.patch"
        eapply "${FILESDIR}/cachy/0011-zstd.patch"
    fi

    # bmq scheduler
    if use bmq; then
        eapply "${FILESDIR}/bmq/0001-prjc.patch"
    fi

    # bore scheduler
    if use bore; then
        if use cachy; then
            eapply "${FILESDIR}/bore/0001-bore-cachy.patch"
        else
            eapply "${FILESDIR}/bore/0001-bore.patch"
        fi
    fi

    # xanmod patch
    if use xanmod; then
        eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
        eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
        eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
        # eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

        eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

        # eapply "${FILESDIR}/xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
        # eapply "${FILESDIR}/xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions-v.patch"
        if ! use bore; then
            eapply "${FILESDIR}/xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
        fi
        # eapply "${FILESDIR}/xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0006-XANMOD-sched-core-Increase-number-of-tasks-to-iterat.patch"
        # eapply "${FILESDIR}/xanmod/xanmod/0007-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0011-XANMOD-blk-wbt-Set-wbt_default_latency_nsec-to-2msec.patch"
        # eapply "${FILESDIR}/xanmod/xanmod/0012-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0013-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0014-XANMOD-mm-Raise-max_map_count-default-value.patch"
        # eapply "${FILESDIR}/xanmod/xanmod/0015-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
        # eapply "${FILESDIR}/xanmod/xanmod/0016-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0017-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
        eapply "${FILESDIR}/xanmod/xanmod/0018-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
    fi

    cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt/kernel/Kconfig.hz"
    eapply_user
}
