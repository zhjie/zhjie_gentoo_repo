# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="17"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa bmq"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
#        UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 5010_enable-cpu-optimizations-universal.patch"

        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi

	kernel-2_src_unpack
}

src_prepare() {
	# cachy patch
	eapply "${FILESDIR}/cachy/6.6/all/0001-cachyos-base-all.patch"
	eapply "${FILESDIR}/cachy/6.6/misc/0001-lrng.patch"

	eapply "${FILESDIR}/0001-high-hz.patch"

	# bmq patch
	if use bmq; then
		eapply "${FILESDIR}/bmq/sched-prjc-20231205-v6.6-r1.patch"
		eapply "${FILESDIR}/bmq/sched-prjc-20231228-implement-missing-CPU-files-stubs-for-cgroups-v1-and-v2.patch"
		eapply "${FILESDIR}/bmq/0001-BMQ-Priority-Squeeze.patch"
		eapply "${FILESDIR}/bmq/0002-workqueue-Implement-non-strict-affinity-scope.patch"
		eapply "${FILESDIR}/bmq/0003-add-WF_CURRENT_CPU-and-externise-ttwu.patch"
		eapply "${FILESDIR}/bmq/0004-add-a-few-helpers-to-wake-up-tasks.patch"
		eapply "${FILESDIR}/bmq/0005-Modify-initial-boot-task-idle-setup.patch"
	fi

	# xanmod patch
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/intel/0001-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/intel/0004-locking-rwsem-spin-faster.patch"

	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0012-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0013-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0014-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0015-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0016-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"

	eapply_user
}
