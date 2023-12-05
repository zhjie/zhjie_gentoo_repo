# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="16"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
        UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 5010_enable-cpu-optimizations-universal.patch"
        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi

	kernel-2_src_unpack
}

src_prepare() {
	# cachy patch
        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
        eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"

	# xanmod patch
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0003-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0004-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0006-locking-rwsem-spin-faster.patch"

	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0004-XANMOD-fair-Increase-wake-up-granularity-time-to-3ms.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0005-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0006-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0007-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0011-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0012-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0013-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0014-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"

	eapply_user
}

