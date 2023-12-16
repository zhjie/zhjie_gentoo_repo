# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.6"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="2eddf0b3e2605954440827878c5fea1f5ffca7f0"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="9"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="16"
MINOR_VERSION="5"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}
	https://cdn.kernel.org/pub/linux/kernel/projects/rt/${K_BASE_VER}/older/patches-${K_BASE_VER}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
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
0085-printk-ringbuffer-Do-not-skip-non-finalized-records-.patch
0086-printk-ringbuffer-Clarify-special-lpos-values.patch
0087-printk-For-suppress_panic_printk-check-for-other-CPU.patch
0088-printk-Add-this_cpu_in_panic.patch
0089-printk-ringbuffer-Cleanup-reader-terminology.patch
0090-printk-Wait-for-all-reserved-records-with-pr_flush.patch
0091-printk-Skip-non-finalized-records-in-panic.patch
0092-printk-Disable-passing-console-lock-owner-completely.patch
0093-printk-Avoid-non-panic-CPUs-flooding-ringbuffer.patch
0094-printk-Add-sparse-notation-to-console_srcu-locking.patch
0095-printk-nbcon-Explicitly-release-ownership-on-failed-.patch
0096-printk-nbcon-Implement-processing-in-port-lock-wrapp.patch
0097-printk-Make-console_is_usable-available-to-nbcon.patch
0098-printk-Let-console_is_usable-handle-nbcon.patch
0099-printk-Add-flags-argument-for-console_is_usable.patch
0100-printk-nbcon-Provide-function-to-flush-using-write_a.patch
0101-printk-Track-registered-boot-consoles.patch
0102-printk-nbcon-Add-nbcon-console-flushing-using-write_.patch
0103-printk-nbcon-Use-nbcon-consoles-in-console_flush_all.patch
0104-printk-nbcon-Add-unsafe-flushing-on-panic.patch
0105-printk-nbcon-Implement-emergency-sections.patch
0106-panic-Mark-emergency-section-in-warn.patch
0107-panic-Mark-emergency-section-in-oops.patch
0108-rcu-Mark-emergency-section-in-rcu-stalls.patch
0109-lockdep-Mark-emergency-section-in-lockdep-splats.patch
0110-printk-nbcon-Introduce-printing-kthreads.patch
0111-printk-nbcon-Add-context-to-console_is_usable.patch
0112-printk-nbcon-Add-printer-thread-wakeups.patch
0113-printk-nbcon-Stop-threads-on-shutdown-reboot.patch
0114-atomic-print-in-printk-context-sometimes.patch
0115-printk-Track-registration-of-console-types.patch
0116-proc-Add-nbcon-support-for-proc-consoles.patch
0117-tty-sysfs-Add-nbcon-support-for-active.patch
0118-printk-nbcon-Provide-function-to-reacquire-ownership.patch
0119-serial-8250-Implement-nbcon-console.patch
0120-printk-Check-printk_deferred_enter-_exit-usage.patch
0121-printk-Add-kthread-for-all-legacy-consoles.patch
0122-serial-8250-revert-drop-lockdep-annotation-from-seri.patch

printk-ringbuffer-Extend-the-sequence-number-properl.patch

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
RISC-V-Probe-misaligned-access-speed-in-parallel.patch
riscv-add-PREEMPT_AUTO-support.patch
riscv-allow-to-enable-RT.patch

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
		eapply "${FILESDIR}/0001-high-hz.patch"
		eapply "${FILESDIR}/0001-lrng.patch"
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
