# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="11"
K_EXP_GENPATCHES_NOUSE="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="11"
MINOR_VERSION="2"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="+naa"

inherit kernel-2
detect_version
EXTRAVERSION="-networkaudio-rt"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}
	https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
"

KV_FULL="${KV_FULL}-rt"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	unpack patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
	# unpack patches-${KV_MAJOR}.${KV_MINOR}-rt${RT_VERSION}.tar.xz
	mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch

	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_EXCLUDE=""
	kernel-2_src_unpack
}

src_prepare() {
	# rt patch
	local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################

# signal_x86__Delay_calling_signals_in_atomic.patch

###########################################################################
# Posted
###########################################################################

# tty/ serial
0001-serial-amba-pl011-Use-uart_prepare_sysrq_char.patch
0002-serial-ar933x-Use-uart_prepare_sysrq_char.patch
0003-serial-bcm63xx-Use-uart_prepare_sysrq_char.patch
0004-serial-meson-Use-uart_prepare_sysrq_char.patch
0005-serial-msm-Use-uart_prepare_sysrq_char.patch
0006-serial-omap-Use-uart_prepare_sysrq_char.patch
0007-serial-pxa-Use-uart_prepare_sysrq_char.patch
0008-serial-sunplus-Use-uart_prepare_sysrq_char.patch
0009-serial-lpc32xx_hs-Use-uart_prepare_sysrq_char-to-han.patch
0010-serial-owl-Use-uart_prepare_sysrq_char-to-handle-sys.patch
0011-serial-rda-Use-uart_prepare_sysrq_char-to-handle-sys.patch
0012-serial-sifive-Use-uart_prepare_sysrq_char-to-handle-.patch
0013-serial-pch-Invoke-handle_rx_to-directly.patch
0014-serial-pch-Make-push_rx-return-void.patch
0015-serial-pch-Don-t-disable-interrupts-while-acquiring-.patch
0016-serial-pch-Don-t-initialize-uart_port-s-spin_lock.patch
0017-serial-pch-Remove-eg20t_port-lock.patch
0018-serial-pch-Use-uart_prepare_sysrq_char.patch

# net, RPS, v5
0001-net-Remove-conditional-threaded-NAPI-wakeup-based-on.patch
0002-net-Allow-to-use-SMP-threads-for-backlog-NAPI.patch
0003-net-Use-backlog-NAPI-to-clean-up-the-defer_list.patch
0004-net-Rename-rps_lock-to-backlog_lock.patch

# perf, sigtrap, v3
0001-perf-Move-irq_work_queue-where-the-event-is-prepared.patch
0002-perf-Enqueue-SIGTRAP-always-via-task_work.patch
0003-perf-Remove-perf_swevent_get_recursion_context-from-.patch
0004-perf-Split-__perf_pending_irq-out-of-perf_pending_ir.patch

###########################################################################
# Post
###########################################################################

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

# Needs discussion first.
softirq-Use-a-dedicated-thread-for-timer-wakeups.patch
rcutorture-Also-force-sched-priority-to-timersd-on-b.patch
tick-Fix-timer-storm-since-introduction-of-timersd.patch
softirq-Wake-ktimers-thread-also-in-softirq.patch
zram-Replace-bit-spinlocks-with-spinlock_t-for-PREEM.patch
# preempt-Put-preempt_enable-within-an-instrumentation.patch

# Sched
0001-sched-core-Provide-a-method-to-check-if-a-task-is-PI.patch
0002-softirq-Add-function-to-preempt-serving-softirqs.patch
0003-time-Allow-to-preempt-after-a-callback.patch

###########################################################################
# John's printk queue
###########################################################################

###########################################################################
# DRM:
###########################################################################
0003-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
0004-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
0005-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
0006-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
0007-drm-i915-skip-DRM_I915_LOW_LEVEL_TRACEPOINTS-with-NO.patch
0008-drm-i915-gt-Queue-and-wait-for-the-irq_work-item.patch
0009-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
0010-drm-i915-Drop-the-irqs_disabled-check.patch
drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# Lazy preemption
###########################################################################
PREEMPT_AUTO.patch

###########################################################################
# ARM/ARM64
###########################################################################
0001-arm-Disable-jump-label-on-PREEMPT_RT.patch
ARM__enable_irq_in_translation_section_permission_fault_handlers.patch
arm-Disable-FAST_GUP-on-PREEMPT_RT-if-HIGHPTE-is-als.patch
# arm64-signal-Use-ARCH_RT_DELAYS_SIGNAL_SEND.patch
0001-ARM-vfp-Provide-vfp_lock-for-VFP-locking.patch
0002-ARM-vfp-Use-vfp_lock-in-vfp_sync_hwstate.patch
0003-ARM-vfp-Use-vfp_lock-in-vfp_support_entry.patch
0004-ARM-vfp-Move-sending-signals-outside-of-vfp_lock-ed-.patch
ARM__Allow_to_enable_RT.patch
ARM64__Allow_to_enable_RT.patch

###########################################################################
# POWERPC
###########################################################################
powerpc__traps__Use_PREEMPT_RT.patch
powerpc_pseries_iommu__Use_a_locallock_instead_local_irq_save.patch
powerpc-pseries-Select-the-generic-memory-allocator.patch
powerpc_kvm__Disable_in-kernel_MPIC_emulation_for_PREEMPT_RT.patch
powerpc_stackprotector__work_around_stack-guard_init_from_atomic.patch
POWERPC__Allow_to_enable_RT.patch

###########################################################################
# RISC-V
###########################################################################
riscv-add-PREEMPT_AUTO-support.patch
riscv-allow-to-enable-RT.patch

# Sysfs file vs uname() -v
sysfs__Add__sys_kernel_realtime_entry.patch

###########################################################################
# RT release version
###########################################################################
# Add_localversion_for_-RT_release.patch
	)

	for p in "${rt_patches[@]}"; do
		eapply "${WORKDIR}/rtpatch/${p}"
	done

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch
	eapply "${FILESDIR}/cachy/all/0001-cachyos-base-all.patch"

	# highhz patch
	eapply "${FILESDIR}"/highhz/*.patch

	# xanmod patch
	eapply "${FILESDIR}/xanmod/intel/0001-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
	eapply "${FILESDIR}/xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
	eapply "${FILESDIR}/xanmod/intel/0004-locking-rwsem-spin-faster.patch"

	eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	# eapply "${FILESDIR}/xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0012-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0013-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0014-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	eapply "${FILESDIR}/xanmod/xanmod/0015-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	# eapply "${FILESDIR}/xanmod/xanmod/0016-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"

        eapply_user
}
