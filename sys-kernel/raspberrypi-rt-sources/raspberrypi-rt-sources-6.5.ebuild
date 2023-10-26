# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.5"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="8b2a6b131d5b3c0fdac5e1582ca0993d06a6d6a4"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="11"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="8"
MINOR_VERSION="2"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}
	https://cdn.kernel.org/pub/linux/kernel/projects/rt/${K_BASE_VER}/patches-${K_BASE_VER}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
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

	unpack patches-${K_BASE_VER}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
	mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch
}

src_prepare() {
	cp -v "${FILESDIR}/${K_BASE_VER}-networkaudio-rt" ${K_BASE_VER}-networkaudio-rt

	local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################
# 0001-kernel-fork-beware-of-__put_task_struct-calling-cont.patch
0002-sched-avoid-false-lockdep-splat-in-put_task_struct.patch

#signal_x86__Delay_calling_signals_in_atomic.patch

###########################################################################
# Posted
###########################################################################
0001-sched-Constrain-locks-in-sched_submit_work.patch
0002-locking-rtmutex-Avoid-unconditional-slowpath-for-DEB.patch
0003-sched-Extract-__schedule_loop.patch
0004-sched-Provide-rt_mutex-specific-scheduler-helpers.patch
0005-locking-rtmutex-Use-rt_mutex-specific-scheduler-help.patch
0006-locking-rtmutex-Add-a-lockdep-assert-to-catch-potent.patch
locking-rtmutex-Acquire-the-hb-lock-via-trylock-afte.patch

# Hacks to get ptrace to work.
0001-signal-Add-proper-comment-about-the-preempt-disable-.patch
0002-signal-Don-t-disable-preemption-in-ptrace_stop-on-PR.patch

#seqlock-Do-the-lockdep-annotation-before-locking-in-.patch
mm-page_alloc-Use-write_seqlock_irqsave-instead-writ.patch

#tick-rcu-fix-false-positive-softirq-work-is-pending-.patch
###########################################################################
# Post
###########################################################################
net-Avoid-the-IPI-to-free-the.patch

###########################################################################
# X86:
###########################################################################
x86__Allow_to_enable_RT.patch
x86__Enable_RT_also_on_32bit.patch

###########################################################################
# For later, not essencial
###########################################################################
# Posted
sched-rt-Don-t-try-push-tasks-if-there-are-none.patch
x86-microcode-Remove-microcode_mutex.patch
ASoC-mediatek-mt8186-Remove-unused-mutex.patch

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
# John's printk queue
###########################################################################
#0001-kdb-do-not-assume-write-callback-available.patch
#0002-printk-Add-NMI-check-to-console_flush_on_panic-and-c.patch
#0003-printk-Consolidate-console-deferred-printing.patch
#0004-printk-Add-per-console-suspended-state.patch
#0005-printk-Add-non-BKL-console-basic-infrastructure.patch
#0006-printk-nobkl-Add-acquire-release-logic.patch
#0007-printk-nobkl-Add-buffer-management.patch
#0008-printk-nobkl-Add-sequence-handling.patch
#0009-printk-nobkl-Add-print-state-functions.patch
#0010-printk-nobkl-Add-emit-function-and-callback-function.patch
#0011-printk-nobkl-Introduce-printer-threads.patch
#0012-printk-nobkl-Add-printer-thread-wakeups.patch
#0013-printk-nobkl-Add-write-context-storage-for-atomic-wr.patch
#0014-printk-nobkl-Provide-functions-for-atomic-write-enfo.patch
#0015-printk-nobkl-Stop-threads-on-shutdown-reboot.patch
#0016-tty-tty_io-Show-non-BKL-consoles-as-active.patch
#0017-proc-consoles-Add-support-for-non-BKL-consoles.patch
#0018-kernel-panic-Add-atomic-write-enforcement-to-warn-pa.patch
#0019-rcu-Add-atomic-write-enforcement-for-rcu-stalls.patch
#0020-printk-Perform-atomic-flush-in-console_flush_on_pani.patch
#0021-printk-only-disable-if-actually-unregistered.patch
#0022-printk-Add-threaded-printing-support-for-BKL-console.patch
#0023-printk-replace-local_irq_save-with-local_lock-for-sa.patch
#0024-serial-8250-implement-non-BKL-console.patch
#printk-Check-only-for-migration-in-printk_deferred_.patch

###########################################################################
# DRM:
###########################################################################
#0003-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
#0004-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
#0005-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
#0006-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
#0007-drm-i915-skip-DRM_I915_LOW_LEVEL_TRACEPOINTS-with-NO.patch
#0008-drm-i915-gt-Queue-and-wait-for-the-irq_work-item.patch
#0009-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
#0010-drm-i915-Drop-the-irqs_disabled-check.patch
#drm-i915-Do-not-disable-preemption-for-resets.patch
#Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# Lazy preemption
###########################################################################
sched__Add_support_for_lazy_preemption.patch
x86_entry__Use_should_resched_in_idtentry_exit_cond_resched.patch
x86__Support_for_lazy_preemption.patch
entry--Fix-the-preempt-lazy-fallout.patch
arm__Add_support_for_lazy_preemption.patch
powerpc__Add_support_for_lazy_preemption.patch
arch_arm64__Add_lazy_preempt_support.patch

###########################################################################
# ARM/ARM64
###########################################################################
0001-arm-Disable-jump-label-on-PREEMPT_RT.patch
ARM__enable_irq_in_translation_section_permission_fault_handlers.patch
# arm64-signal-Use-ARCH_RT_DELAYS_SIGNAL_SEND.patch
tty_serial_omap__Make_the_locking_RT_aware.patch
tty_serial_pl011__Make_the_locking_work_on_RT.patch
0003-ARM-vfp-Provide-vfp_lock-for-VFP-locking.patch
0004-ARM-vfp-Use-vfp_lock-in-vfp_sync_hwstate.patch
0005-ARM-vfp-Use-vfp_lock-in-vfp_entry.patch
ARM__Allow_to_enable_RT.patch
ARM64__Allow_to_enable_RT.patch

###########################################################################
# POWERPC
###########################################################################
#powerpc__traps__Use_PREEMPT_RT.patch
#powerpc_pseries_iommu__Use_a_locallock_instead_local_irq_save.patch
#powerpc-imc-pmu-Use-the-correct-spinlock-initializer.patch
#powerpc-pseries-Select-the-generic-memory-allocator.patch
#powerpc_kvm__Disable_in-kernel_MPIC_emulation_for_PREEMPT_RT.patch
#powerpc_stackprotector__work_around_stack-guard_init_from_atomic.patch
#POWERPC__Allow_to_enable_RT.patch

# Sysfs file vs uname() -v
sysfs__Add__sys_kernel_realtime_entry.patch

###########################################################################
# RT release version
###########################################################################
#Add_localversion_for_-RT_release.patch
        )
	for p in "${rt_patches[@]}"; do
		eapply "${WORKDIR}/rtpatch/${p}"
        done
#	eapply "${FILESDIR}/patch-${K_BASE_VER}-rt${RT_VERSION}"
#	eapply "${WORKDIR}"/rtpatch/*.patch

	# genpatch
	eapply "${WORKDIR}"/genpatch/*.patch

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch and rt patch
	if use cachy; then
	        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
	        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"
#		eapply "${FILESDIR}/cachy/6.5/misc/0001-rt.patch"
#	        eapply "${FILESDIR}/rt-arm-arm64-${K_BASE_VER}.patch"
#	else
#		eapply "${FILESDIR}/patch-${K_BASE_VER}-rt${RT_VERSION}"
	fi

	# xanmod patch
	if use xanmod; then
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0006-locking-rwsem-spin-faster.patch"

		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0012-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0017-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"
	fi

        eapply_user
}
