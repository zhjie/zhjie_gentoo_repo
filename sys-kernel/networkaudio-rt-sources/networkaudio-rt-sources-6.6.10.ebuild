# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="12"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="19"
MINOR_VERSION="10"

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

# DRM AMD GPU
0001-drm-amd-display-Remove-migrate_en-dis-from-dc_fpu_be.patch
0002-drm-amd-display-Simplify-the-per-CPU-usage.patch
0003-drm-amd-display-Add-a-warning-if-the-FPU-is-used-out.patch
0004-drm-amd-display-Move-the-memory-allocation-out-of-dc.patch
0005-drm-amd-display-Move-the-memory-allocation-out-of-dc.patch

# printk related
srcu-Use-try-lock-lockdep-annotation-for-NMI-safe-ac.patch

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
0001-serial-core-Provide-port-lock-wrappers.patch
0002-serial-core-Use-lock-wrappers.patch
0003-serial-21285-Use-port-lock-wrappers.patch
0004-serial-8250_aspeed_vuart-Use-port-lock-wrappers.patch
0005-serial-8250_bcm7271-Use-port-lock-wrappers.patch
0006-serial-8250-Use-port-lock-wrappers.patch
0007-serial-8250_dma-Use-port-lock-wrappers.patch
0008-serial-8250_dw-Use-port-lock-wrappers.patch
0009-serial-8250_exar-Use-port-lock-wrappers.patch
0010-serial-8250_fsl-Use-port-lock-wrappers.patch
0011-serial-8250_mtk-Use-port-lock-wrappers.patch
0012-serial-8250_omap-Use-port-lock-wrappers.patch
0013-serial-8250_pci1xxxx-Use-port-lock-wrappers.patch
0014-serial-altera_jtaguart-Use-port-lock-wrappers.patch
0015-serial-altera_uart-Use-port-lock-wrappers.patch
0016-serial-amba-pl010-Use-port-lock-wrappers.patch
0017-serial-amba-pl011-Use-port-lock-wrappers.patch
0018-serial-apb-Use-port-lock-wrappers.patch
0019-serial-ar933x-Use-port-lock-wrappers.patch
0020-serial-arc_uart-Use-port-lock-wrappers.patch
0021-serial-atmel-Use-port-lock-wrappers.patch
0022-serial-bcm63xx-uart-Use-port-lock-wrappers.patch
0023-serial-cpm_uart-Use-port-lock-wrappers.patch
0024-serial-digicolor-Use-port-lock-wrappers.patch
0025-serial-dz-Use-port-lock-wrappers.patch
0026-serial-linflexuart-Use-port-lock-wrappers.patch
0027-serial-fsl_lpuart-Use-port-lock-wrappers.patch
0028-serial-icom-Use-port-lock-wrappers.patch
0029-serial-imx-Use-port-lock-wrappers.patch
0030-serial-ip22zilog-Use-port-lock-wrappers.patch
0031-serial-jsm-Use-port-lock-wrappers.patch
0032-serial-liteuart-Use-port-lock-wrappers.patch
0033-serial-lpc32xx_hs-Use-port-lock-wrappers.patch
0034-serial-ma35d1-Use-port-lock-wrappers.patch
0035-serial-mcf-Use-port-lock-wrappers.patch
0036-serial-men_z135_uart-Use-port-lock-wrappers.patch
0037-serial-meson-Use-port-lock-wrappers.patch
0038-serial-milbeaut_usio-Use-port-lock-wrappers.patch
0039-serial-mpc52xx-Use-port-lock-wrappers.patch
0040-serial-mps2-uart-Use-port-lock-wrappers.patch
0041-serial-msm-Use-port-lock-wrappers.patch
0042-serial-mvebu-uart-Use-port-lock-wrappers.patch
0043-serial-omap-Use-port-lock-wrappers.patch
0044-serial-owl-Use-port-lock-wrappers.patch
0045-serial-pch-Use-port-lock-wrappers.patch
0046-serial-pic32-Use-port-lock-wrappers.patch
0047-serial-pmac_zilog-Use-port-lock-wrappers.patch
0048-serial-pxa-Use-port-lock-wrappers.patch
0049-serial-qcom-geni-Use-port-lock-wrappers.patch
0050-serial-rda-Use-port-lock-wrappers.patch
0051-serial-rp2-Use-port-lock-wrappers.patch
0052-serial-sa1100-Use-port-lock-wrappers.patch
0053-serial-samsung_tty-Use-port-lock-wrappers.patch
0054-serial-sb1250-duart-Use-port-lock-wrappers.patch
0055-serial-sc16is7xx-Use-port-lock-wrappers.patch
0056-serial-tegra-Use-port-lock-wrappers.patch
0057-serial-core-Use-port-lock-wrappers.patch
0058-serial-mctrl_gpio-Use-port-lock-wrappers.patch
0059-serial-txx9-Use-port-lock-wrappers.patch
0060-serial-sh-sci-Use-port-lock-wrappers.patch
0061-serial-sifive-Use-port-lock-wrappers.patch
0062-serial-sprd-Use-port-lock-wrappers.patch
0063-serial-st-asc-Use-port-lock-wrappers.patch
0064-serial-stm32-Use-port-lock-wrappers.patch
0065-serial-sunhv-Use-port-lock-wrappers.patch
0066-serial-sunplus-uart-Use-port-lock-wrappers.patch
0067-serial-sunsab-Use-port-lock-wrappers.patch
0068-serial-sunsu-Use-port-lock-wrappers.patch
0069-serial-sunzilog-Use-port-lock-wrappers.patch
0070-serial-timbuart-Use-port-lock-wrappers.patch
0071-serial-uartlite-Use-port-lock-wrappers.patch
0072-serial-ucc_uart-Use-port-lock-wrappers.patch
0073-serial-vt8500-Use-port-lock-wrappers.patch
0074-serial-xilinx_uartps-Use-port-lock-wrappers.patch
0075-printk-Add-non-BKL-nbcon-console-basic-infrastructur.patch
0076-printk-nbcon-Add-acquire-release-logic.patch
0077-printk-Make-static-printk-buffers-available-to-nbcon.patch
0078-printk-nbcon-Add-buffer-management.patch
0079-printk-nbcon-Add-ownership-state-functions.patch
0080-printk-nbcon-Add-sequence-handling.patch
0081-printk-nbcon-Add-emit-function-and-callback-function.patch
0082-printk-nbcon-Allow-drivers-to-mark-unsafe-regions-an.patch
0083-printk-fix-illegal-pbufs-access-for-CONFIG_PRINTK.patch
0084-printk-Reduce-pr_flush-pooling-time.patch
0085-printk-nbcon-Relocate-32bit-seq-macros.patch
0086-printk-Adjust-mapping-for-32bit-seq-macros.patch
0087-printk-Use-prb_first_seq-as-base-for-32bit-seq-macro.patch
0088-printk-ringbuffer-Do-not-skip-non-finalized-records-.patch
0089-printk-ringbuffer-Clarify-special-lpos-values.patch
0090-printk-For-suppress_panic_printk-check-for-other-CPU.patch
0091-printk-Add-this_cpu_in_panic.patch
0092-printk-ringbuffer-Cleanup-reader-terminology.patch
0093-printk-Wait-for-all-reserved-records-with-pr_flush.patch
0094-printk-ringbuffer-Skip-non-finalized-records-in-pani.patch
0095-printk-ringbuffer-Consider-committed-as-finalized-in.patch
0096-printk-Disable-passing-console-lock-owner-completely.patch
0097-printk-Avoid-non-panic-CPUs-writing-to-ringbuffer.patch
0098-panic-Flush-kernel-log-buffer-at-the-end.patch
0099-printk-Consider-nbcon-boot-consoles-on-seq-init.patch
0100-printk-Add-sparse-notation-to-console_srcu-locking.patch
0101-printk-nbcon-Ensure-ownership-release-on-failed-emit.patch
0102-printk-Check-printk_deferred_enter-_exit-usage.patch
0103-printk-nbcon-Implement-processing-in-port-lock-wrapp.patch
0104-printk-nbcon-Add-driver_enter-driver_exit-console-ca.patch
0105-printk-Make-console_is_usable-available-to-nbcon.patch
0106-printk-Let-console_is_usable-handle-nbcon.patch
0107-printk-Add-flags-argument-for-console_is_usable.patch
0108-printk-nbcon-Provide-function-to-flush-using-write_a.patch
0109-printk-Track-registered-boot-consoles.patch
0110-printk-nbcon-Use-nbcon-consoles-in-console_flush_all.patch
0111-printk-nbcon-Assign-priority-based-on-CPU-state.patch
0112-printk-nbcon-Add-unsafe-flushing-on-panic.patch
0113-printk-Avoid-console_lock-dance-if-no-legacy-or-boot.patch
0114-printk-Track-nbcon-consoles.patch
0115-printk-Coordinate-direct-printing-in-panic.patch
0116-printk-nbcon-Implement-emergency-sections.patch
0117-panic-Mark-emergency-section-in-warn.patch
0118-panic-Mark-emergency-section-in-oops.patch
0119-rcu-Mark-emergency-section-in-rcu-stalls.patch
0120-lockdep-Mark-emergency-section-in-lockdep-splats.patch
0121-printk-nbcon-Introduce-printing-kthreads.patch
0122-printk-Atomic-print-in-printk-context-on-shutdown.patch
0123-printk-nbcon-Add-context-to-console_is_usable.patch
0124-printk-nbcon-Add-printer-thread-wakeups.patch
0125-printk-nbcon-Stop-threads-on-shutdown-reboot.patch
0126-printk-nbcon-Start-printing-threads.patch
0127-proc-Add-nbcon-support-for-proc-consoles.patch
0128-tty-sysfs-Add-nbcon-support-for-active.patch
0129-printk-nbcon-Provide-function-to-reacquire-ownership.patch
0130-serial-core-Provide-low-level-functions-to-port-lock.patch
0131-serial-8250-Switch-to-nbcon-console.patch
0132-printk-Add-kthread-for-all-legacy-consoles.patch
0133-serial-8250-revert-drop-lockdep-annotation-from-seri.patch
0134-printk-Avoid-false-positive-lockdep-report-for-legac.patch

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
drm-i915-Do-not-disable-preemption-for-resets.patch
drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# Lazy preemption
###########################################################################
PREEMPT_AUTO.patch

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

	# cachy patch
	eapply "${FILESDIR}/cachy/6.6/all/0001-cachyos-base-all.patch"
	eapply "${FILESDIR}/cachy/6.6/misc/0001-lrng.patch"

	eapply "${FILESDIR}/0001-high-hz.patch"

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
	# eapply "${FILESDIR}/xanmod/linux-6.6.y-xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
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

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
