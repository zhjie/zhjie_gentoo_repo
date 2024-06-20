# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.9"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="380df7b7938d3c3ba1d0d0b472a810fd38061329"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="6"
K_EXP_GENPATCHES_NOUSE="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="5"
MINOR_VERSION="0"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version
EXTRAVERSION="-networkaudio-rt${RT_VERSION}"

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

S="${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz

	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${S}/.git"
	mkdir "${WORKDIR}"/genpatch
	mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/

	# unpack patches-${K_BASE_VER}.${MINOR_VERSION}-rt${RT_VERSION}.tar.xz
	unpack patches-${K_BASE_VER}-rt${RT_VERSION}.tar.xz

	mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch
	echo "${EXTRAVERSION}"
	unpack_set_extraversion
}

src_prepare() {
	# cp -vf "${FILESDIR}/config/${K_BASE_VER}-networkaudio-rt" ${K_BASE_VER}-networkaudio-rt

	local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################

# signal_x86__Delay_calling_signals_in_atomic.patch

###########################################################################
# Posted
###########################################################################

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

# locking.
drm-ttm-tests-Let-ttm_bo_test-consider-different-ww_.patch

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
0001-printk-Add-notation-to-console_srcu-locking.patch
0002-printk-Properly-deal-with-nbcon-consoles-on-seq-init.patch
0003-printk-nbcon-Remove-return-value-for-write_atomic.patch
0004-printk-Check-printk_deferred_enter-_exit-usage.patch
0005-printk-nbcon-Add-detailed-doc-for-write_atomic.patch
0006-printk-nbcon-Add-callbacks-to-synchronize-with-drive.patch
0007-printk-nbcon-Use-driver-synchronization-while-un-reg.patch
0008-serial-core-Provide-low-level-functions-to-lock-port.patch
0009-serial-core-Introduce-wrapper-to-set-uart_port-cons.patch
0010-console-Improve-console_srcu_read_flags-comments.patch
0011-nbcon-Provide-functions-for-drivers-to-acquire-conso.patch
0012-serial-core-Implement-processing-in-port-lock-wrappe.patch
0013-printk-nbcon-Do-not-rely-on-proxy-headers.patch
0014-printk-Make-console_is_usable-available-to-nbcon.patch
0015-printk-Let-console_is_usable-handle-nbcon.patch
0016-printk-Add-flags-argument-for-console_is_usable.patch
0017-printk-nbcon-Add-helper-to-assign-priority-based-on-.patch
0018-printk-nbcon-Provide-function-to-flush-using-write_a.patch
0019-printk-Track-registered-boot-consoles.patch
0020-printk-nbcon-Use-nbcon-consoles-in-console_flush_all.patch
0021-printk-nbcon-Add-unsafe-flushing-on-panic.patch
0022-printk-Avoid-console_lock-dance-if-no-legacy-or-boot.patch
0023-printk-Track-nbcon-consoles.patch
0024-printk-Coordinate-direct-printing-in-panic.patch
0025-printk-nbcon-Implement-emergency-sections.patch
0026-panic-Mark-emergency-section-in-warn.patch
0027-panic-Mark-emergency-section-in-oops.patch
0028-rcu-Mark-emergency-sections-in-rcu-stalls.patch
0029-lockdep-Mark-emergency-sections-in-lockdep-splats.patch
0030-printk-nbcon-Introduce-printing-kthreads.patch
0031-printk-Atomic-print-in-printk-context-on-shutdown.patch
0032-printk-nbcon-Add-context-to-console_is_usable.patch
0033-printk-nbcon-Add-printer-thread-wakeups.patch
0034-printk-nbcon-Stop-threads-on-shutdown-reboot.patch
0035-printk-nbcon-Start-printing-threads.patch
0036-printk-Provide-helper-for-message-prepending.patch
0037-printk-nbcon-Show-replay-message-on-takeover.patch
0038-proc-consoles-Add-notation-to-c_start-c_stop.patch
0039-proc-Add-nbcon-support-for-proc-consoles.patch
0040-tty-sysfs-Add-nbcon-support-for-active.patch
0041-printk-nbcon-Provide-function-to-reacquire-ownership.patch
0042-serial-8250-Switch-to-nbcon-console.patch
0043-serial-8250-Revert-drop-lockdep-annotation-from-seri.patch
0044-printk-Add-kthread-for-all-legacy-consoles.patch
0045-printk-Provide-threadprintk-boot-argument.patch
0046-printk-Avoid-false-positive-lockdep-report-for-legac.patch

###########################################################################
# DRM:
###########################################################################
# https://lore.kernel.org/all/20240405142737.920626-1-bigeasy@linutronix.de/
0003-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
0004-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
0005-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
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

	# eapply "${FILESDIR}/automagic-arm64.patch"

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
		# eapply -R "${FILESDIR}/highhz/0001-high-hz-2.patch"
		# eapply "${FILESDIR}/cachy/all/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/cachy/0001-aes-crypto.patch"
		eapply "${FILESDIR}/cachy/0003-bbr3.patch"
		eapply "${FILESDIR}/cachy/0004-cachy.patch"
		eapply "${FILESDIR}/cachy/0006-fixes.patch"
		eapply "${FILESDIR}/cachy/0010-zstd.patch"

		# eapply "${FILESDIR}/highhz/0001-high-hz-3.patch"
	fi

	# xanmod patch
	if use xanmod; then
	       	eapply "${FILESDIR}/xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
	       	eapply "${FILESDIR}/xanmod/intel/0003-firmware-Enable-stateless-firmware-loading.patch"
	        eapply "${FILESDIR}/xanmod/intel/0004-locking-rwsem-spin-faster.patch"
	       	# eapply "${FILESDIR}/xanmod/intel/0005-drivers-initialize-ata-before-graphics.patch"

	       	eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	       	# eapply "${FILESDIR}/xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions-v.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0010-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	        eapply "${FILESDIR}/xanmod/xanmod/0012-XANMOD-mm-Raise-max_map_count-default-value.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0013-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0014-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
	        eapply "${FILESDIR}/xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	       	eapply "${FILESDIR}/xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0017-XANMOD-scripts-setlocalversion-remove-tag-for-git-re.patch"
	       	# eapply "${FILESDIR}/xanmod/xanmod/0018-XANMOD-scripts-setlocalversion-Move-localversion-fil.patch"
	fi

	cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt/kernel/Kconfig.hz"
        eapply_user
}
