# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.6"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="495ec9e419cb6152d3961b8f5e1174817a34345b"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="3"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="15"
MINOR_VERSION="0"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}
	https://cdn.kernel.org/pub/linux/kernel/projects/rt/${K_BASE_VER}/older/patches-${K_BASE_VER}-rt${RT_VERSION}.tar.xz
"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.6-r4"

EXTRAVERSION="-raspberrypi-rt"
S="${WORKDIR}/linux-${K_BASE_VER}${EXTRAVERSION}"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz

	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${WORKDIR}"/1515_selinux-fix-handling-of-empty-opts.patch
	rm -rfv "${S}/.git"
	mkdir "${WORKDIR}"/genpatch
	mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/

#	unpack patches-${K_BASE_VER}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
	unpack patches-${K_BASE_VER}-rt${RT_VERSION}.tar.xz

	mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch
}

src_prepare() {
	cp -vf "${FILESDIR}/${K_BASE_VER}-networkaudio-rt" ${K_BASE_VER}-networkaudio-rt
	eapply "${FILESDIR}/Add-extra-version-networkaudio-rt.patch"

	local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################

# signal_x86__Delay_calling_signals_in_atomic.patch

###########################################################################
# Posted
###########################################################################
0001-sched-Constrain-locks-in-sched_submit_work.patch
0002-locking-rtmutex-Avoid-unconditional-slowpath-for-DEB.patch
0003-sched-Extract-__schedule_loop.patch
0004-sched-Provide-rt_mutex-specific-scheduler-helpers.patch
0005-locking-rtmutex-Use-rt_mutex-specific-scheduler-help.patch
0006-locking-rtmutex-Add-a-lockdep-assert-to-catch-potent.patch
0007-futex-pi-Fix-recursive-rt_mutex-waiter-state.patch

# Hacks to get ptrace to work.
0001-signal-Add-proper-comment-about-the-preempt-disable-.patch
0002-signal-Don-t-disable-preemption-in-ptrace_stop-on-PR.patch

###########################################################################
# Post
###########################################################################
net-Avoid-the-IPI-to-free-the.patch

###########################################################################
# For later, not essencial
###########################################################################
# Posted
sched-rt-Don-t-try-push-tasks-if-there-are-none.patch

# Needs discussion first.
softirq-Use-a-dedicated-thread-for-timer-wakeups.patch
rcutorture-Also-force-sched-priority-to-timersd-on-b.patch
tick-Fix-timer-storm-since-introduction-of-timersd.patch
softirq-Wake-ktimers-thread-also-in-softirq.patch
zram-Replace-bit-spinlocks-with-spinlock_t-for-PREEM.patch
preempt-Put-preempt_enable-within-an-instrumentation.patch

# Sched
0001-sched-core-Provide-a-method-to-check-if-a-task-is-PI.patch
0002-softirq-Add-function-to-preempt-serving-softirqs.patch
0003-time-Allow-to-preempt-after-a-callback.patch

###########################################################################
# Lazy preemption
###########################################################################
PREEMPT_AUTO.patch

###########################################################################
# ARM/ARM64
###########################################################################
0001-arm-Disable-jump-label-on-PREEMPT_RT.patch
ARM__enable_irq_in_translation_section_permission_fault_handlers.patch
# arm64-signal-Use-ARCH_RT_DELAYS_SIGNAL_SEND.patch
# tty_serial_omap__Make_the_locking_RT_aware.patch
# tty_serial_pl011__Make_the_locking_work_on_RT.patch
0001-ARM-vfp-Provide-vfp_lock-for-VFP-locking.patch
0002-ARM-vfp-Use-vfp_lock-in-vfp_sync_hwstate.patch
0003-ARM-vfp-Use-vfp_lock-in-vfp_support_entry.patch
0004-ARM-vfp-Move-sending-signals-outside-of-vfp_lock-ed-.patch
ARM__Allow_to_enable_RT.patch
ARM64__Allow_to_enable_RT.patch

# Sysfs file vs uname() -v
sysfs__Add__sys_kernel_realtime_entry.patch
        )

	for p in "${rt_patches[@]}"; do
		eapply "${WORKDIR}/rtpatch/${p}"
        done

	eapply "${FILESDIR}/automagic-arm64.patch"

	# genpatch
	eapply "${WORKDIR}"/genpatch/*.patch

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch
        if use cachy; then
		eapply "${FILESDIR}/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/0001-lrng.patch"
		eapply "${FILESDIR}/0001-high-hz.patch"
	fi

	# xanmod patch
	if use xanmod; then
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/intel/0004-locking-rwsem-spin-faster.patch"

		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

                # eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
                # eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
                # eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0013-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0014-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
		eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0015-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	fi

        eapply_user
}
