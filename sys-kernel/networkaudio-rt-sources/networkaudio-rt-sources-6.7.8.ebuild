# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="12"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="6"
MINOR_VERSION="0"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="+naa"

inherit kernel-2
detect_version
EXTRAVERSION="-networkaudio-rt"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}
	https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/patches-${KV_MAJOR}.${KV_MINOR}-rt${RT_VERSION}.tar.xz
"

KV_FULL="${KV_FULL}-rt"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	# unpack patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
	unpack patches-${KV_MAJOR}.${KV_MINOR}-rt${RT_VERSION}.tar.xz
	mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch

	UNIPATCH_LIST_DEFAULT=""
#        UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 5010_enable-cpu-optimizations-universal.patch"

        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi

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
# printk related
#srcu-Use-try-lock-lockdep-annotation-for-NMI-safe-ac.patch

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
0001-printk-nbcon-Relocate-32bit-seq-macros.patch
0002-printk-Adjust-mapping-for-32bit-seq-macros.patch
0003-printk-Use-prb_first_seq-as-base-for-32bit-seq-macro.patch
0004-printk-ringbuffer-Do-not-skip-non-finalized-records-.patch
0005-printk-ringbuffer-Clarify-special-lpos-values.patch
0006-printk-For-suppress_panic_printk-check-for-other-CPU.patch
0007-printk-Add-this_cpu_in_panic.patch
0008-printk-ringbuffer-Cleanup-reader-terminology.patch
0009-printk-Wait-for-all-reserved-records-with-pr_flush.patch
0010-printk-ringbuffer-Skip-non-finalized-records-in-pani.patch
0011-printk-ringbuffer-Consider-committed-as-finalized-in.patch
0012-printk-Disable-passing-console-lock-owner-completely.patch
0013-printk-Avoid-non-panic-CPUs-writing-to-ringbuffer.patch
0014-panic-Flush-kernel-log-buffer-at-the-end.patch
0015-printk-Consider-nbcon-boot-consoles-on-seq-init.patch
0016-printk-Add-sparse-notation-to-console_srcu-locking.patch
0017-printk-nbcon-Ensure-ownership-release-on-failed-emit.patch
0018-printk-Check-printk_deferred_enter-_exit-usage.patch
0019-printk-nbcon-Implement-processing-in-port-lock-wrapp.patch
0020-printk-nbcon-Add-driver_enter-driver_exit-console-ca.patch
0021-printk-Make-console_is_usable-available-to-nbcon.patch
0022-printk-Let-console_is_usable-handle-nbcon.patch
0023-printk-Add-flags-argument-for-console_is_usable.patch
0024-printk-nbcon-Provide-function-to-flush-using-write_a.patch
0025-printk-Track-registered-boot-consoles.patch
0026-printk-nbcon-Use-nbcon-consoles-in-console_flush_all.patch
0027-printk-nbcon-Assign-priority-based-on-CPU-state.patch
0028-printk-nbcon-Add-unsafe-flushing-on-panic.patch
0029-printk-Avoid-console_lock-dance-if-no-legacy-or-boot.patch
0030-printk-Track-nbcon-consoles.patch
0031-printk-Coordinate-direct-printing-in-panic.patch
0032-printk-nbcon-Implement-emergency-sections.patch
0033-panic-Mark-emergency-section-in-warn.patch
0034-panic-Mark-emergency-section-in-oops.patch
0035-rcu-Mark-emergency-section-in-rcu-stalls.patch
0036-lockdep-Mark-emergency-section-in-lockdep-splats.patch
0037-printk-nbcon-Introduce-printing-kthreads.patch
0038-printk-Atomic-print-in-printk-context-on-shutdown.patch
0039-printk-nbcon-Add-context-to-console_is_usable.patch
0040-printk-nbcon-Add-printer-thread-wakeups.patch
0041-printk-nbcon-Stop-threads-on-shutdown-reboot.patch
0042-printk-nbcon-Start-printing-threads.patch
0043-proc-Add-nbcon-support-for-proc-consoles.patch
0044-tty-sysfs-Add-nbcon-support-for-active.patch
0045-printk-nbcon-Provide-function-to-reacquire-ownership.patch
0046-serial-core-Provide-low-level-functions-to-port-lock.patch
0047-serial-8250-Switch-to-nbcon-console.patch
0048-printk-Add-kthread-for-all-legacy-consoles.patch
0049-serial-8250-revert-drop-lockdep-annotation-from-seri.patch
0050-printk-Avoid-false-positive-lockdep-report-for-legac.patch

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
# arm64-signal-Use-ARCH_RT_DELAYS_SIGNAL_SEND.patch
tty_serial_omap__Make_the_locking_RT_aware.patch
tty_serial_pl011__Make_the_locking_work_on_RT.patch
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

	# EEVDF fixes from 6.8
        eapply "${FILESDIR}/sched-20231107-001-sort-the-rbtree-by-virtual-deadline.patch"
        eapply "${FILESDIR}/sched-20231107-002-O1-fastpath-for-task-selection.patch"
        eapply "${FILESDIR}/sched-20231122-avoid-underestimation-of-task-utilization.patch"
	eapply "${FILESDIR}/sched-20240226-return-leftmost-entity-in-pick_eevdf.patch"

	# cachy patch
	eapply "${FILESDIR}/0001-cachyos-base-all-rev.patch"
	eapply "${FILESDIR}/0001-lrng.patch"

	eapply "${FILESDIR}/0001-high-hz.patch"
	eapply "${FILESDIR}/0001-high-hz-1.patch"
	eapply "${FILESDIR}/0001-high-hz-2.patch"

	# xanmod patch
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0001-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0004-locking-rwsem-spin-faster.patch"

	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0012-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0013-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0014-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0015-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0016-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"

        eapply_user
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
