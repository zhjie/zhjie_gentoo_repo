# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="12"
K_EXP_GENPATCHES_NOUSE="1"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa bmq +bore"
REQUIRED_USE="
	bmq? ( !bore )
	bore? ( !bmq )
"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
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
	eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
	eapply "${FILESDIR}/cachy/0002-bbr3.patch"
	eapply "${FILESDIR}/cachy/0003-block.patch"
	eapply "${FILESDIR}/cachy/0004-cachy.patch"
	eapply "${FILESDIR}/cachy/0005-crypto.patch"
	eapply "${FILESDIR}/cachy/0006-fixes.patch"
	eapply "${FILESDIR}/cachy/0007-intel-pstate.patch"
	eapply "${FILESDIR}/cachy/0012-zstd.patch"

	# highhz patch
	eapply "${FILESDIR}"/highhz/*.patch

	# bmq/pds scheduler
	if use bmq; then
		eapply "${FILESDIR}/bmq/5020_BMQ-and-PDS-io-scheduler-v6.9-r2.patch"
	fi

	# bore scheduler
	if use bore; then
		eapply "${FILESDIR}/cachy/sched/0001-bore-cachy.patch"
	fi

	# xanmod patch
	eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
	eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
	eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
	# eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

	eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	# eapply "${FILESDIR}/xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions-v.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	# apply "${FILESDIR}/xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0006-XANMOD-sched-core-Increase-number-of-tasks-to-iterat.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0007-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0011-XANMOD-blk-wbt-Set-wbt_default_latency_nsec-to-2msec.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0012-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0013-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0014-XANMOD-mm-Raise-max_map_count-default-value.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0015-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0016-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0017-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	#eapply "${FILESDIR}/xanmod/xanmod/0018-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0019-XANMOD-scripts-setlocalversion-remove-tag-for-git-re.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0020-XANMOD-scripts-setlocalversion-Move-localversion-fil.patch"

	eapply_user
}
