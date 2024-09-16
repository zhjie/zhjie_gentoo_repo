# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"
IUSE="+naa"

EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
EGIT_BRANCH="rpi-${KV_MAJOR}.${KV_MINOR}.y"
EGIT_COMMIT="191b7e05e5e8db6dcb308220020995fa6885c7ed"

RT_VERSION="rt7"
MINOR_VERSION="0"

# RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}-${RT_VERSION}.tar.xz
RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/${RT_PATCH}"

SRC_URI="${GENPATCHES_URI} ${RT_URI}"

S="${WORKDIR}/linux-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}-raspberrypi-rt"
EXTRAVERSION="-networkaudio-rt${RT_VERSION}"

src_unpack() {
    git-r3_src_unpack
    mv "${WORKDIR}/${PF}" "${S}"

    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.base.tar.xz
    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.extras.tar.xz

    rm -rfv "${WORKDIR}"/10*.patch
    rm -rfv "${S}/.git"
    mkdir "${WORKDIR}"/genpatch
    mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/

    unpack "${RT_PATCH}"
    mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch

    unpack_set_extraversion
}

src_prepare() {
    # genpatch
    eapply "${WORKDIR}"/genpatch/*.patch

    local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################

###########################################################################
# Posted
###########################################################################
crypto-x86-aes-gcm-fix-PREEMPT_RT-issue-in-gcm_crypt.patch

###########################################################################
# John's printk queue
###########################################################################
# printk-for-6.12 from the printk tree.
0001-printk-Add-notation-to-console_srcu-locking.patch
0002-printk-nbcon-Consolidate-alloc-and-init.patch
0003-printk-Properly-deal-with-nbcon-consoles-on-seq-init.patch
0004-printk-Check-printk_deferred_enter-_exit-usage.patch
0005-printk-nbcon-Clarify-rules-of-the-owner-waiter-match.patch
0006-printk-nbcon-Remove-return-value-for-write_atomic.patch
0007-printk-nbcon-Add-detailed-doc-for-write_atomic.patch
0008-printk-nbcon-Add-callbacks-to-synchronize-with-drive.patch
0009-printk-nbcon-Use-driver-synchronization-while-un-reg.patch
0010-serial-core-Provide-low-level-functions-to-lock-port.patch
0011-serial-core-Introduce-wrapper-to-set-uart_port-cons.patch
0012-console-Improve-console_srcu_read_flags-comments.patch
0013-nbcon-Add-API-to-acquire-context-for-non-printing-op.patch
0014-serial-core-Acquire-nbcon-context-in-port-lock-wrapp.patch
0015-printk-nbcon-Do-not-rely-on-proxy-headers.patch
0016-printk-Make-console_is_usable-available-to-nbcon.c.patch
0017-printk-Let-console_is_usable-handle-nbcon.patch
0018-printk-Add-flags-argument-for-console_is_usable.patch
0019-printk-nbcon-Add-helper-to-assign-priority-based-on-.patch
0020-printk-nbcon-Provide-function-to-flush-using-write_a.patch
0021-printk-Track-registered-boot-consoles.patch
0022-printk-nbcon-Use-nbcon-consoles-in-console_flush_all.patch
0023-printk-Add-is_printk_legacy_deferred.patch
0024-printk-nbcon-Flush-new-records-on-device_release.patch
0025-printk-Flush-nbcon-consoles-first-on-panic.patch
0026-printk-nbcon-Add-unsafe-flushing-on-panic.patch
0027-printk-Avoid-console_lock-dance-if-no-legacy-or-boot.patch
0028-printk-Track-nbcon-consoles.patch
0029-printk-Coordinate-direct-printing-in-panic.patch
0030-printk-Add-helper-for-flush-type-logic.patch
0031-printk-nbcon-Implement-emergency-sections.patch
0032-panic-Mark-emergency-section-in-warn.patch
0033-panic-Mark-emergency-section-in-oops.patch
0034-rcu-Mark-emergency-sections-in-rcu-stalls.patch
0035-lockdep-Mark-emergency-sections-in-lockdep-splats.patch
0036-printk-Use-the-BITS_PER_LONG-macro.patch
0037-printk-nbcon-Use-raw_cpu_ptr-instead-of-open-coding.patch
0038-printk-nbcon-Add-function-for-printers-to-reacquire-.patch
0039-printk-Fail-pr_flush-if-before-SYSTEM_SCHEDULING.patch
0040-printk-Flush-console-on-unregister_console.patch
0041-printk-nbcon-Add-context-to-usable-and-emit.patch
0042-printk-nbcon-Init-nbcon_seq-to-highest-possible.patch
0043-printk-nbcon-Introduce-printer-kthreads.patch
0044-printk-nbcon-Relocate-nbcon_atomic_emit_one.patch
0045-printk-nbcon-Use-thread-callback-if-in-task-context-.patch
0046-printk-nbcon-Rely-on-kthreads-for-normal-operation.patch
0047-printk-Provide-helper-for-message-prepending.patch
0048-printk-nbcon-Show-replay-message-on-takeover.patch
0049-proc-consoles-Add-notation-to-c_start-c_stop.patch
0050-proc-Add-nbcon-support-for-proc-consoles.patch
0051-tty-sysfs-Add-nbcon-support-for-active.patch
0052-printk-Implement-legacy-printer-kthread-for-PREEMPT_.patch
0053-printk-nbcon-Assign-nice-20-for-printing-threads.patch
0054-printk-Avoid-false-positive-lockdep-report-for-legac.patch
# Atomic console
0053-serial-8250-Switch-to-nbcon-console.patch
0054-serial-8250-Revert-drop-lockdep-annotation-from-seri.patch

###########################################################################
# Post
###########################################################################

###########################################################################
# Enabling
###########################################################################
x86__Allow_to_enable_RT.patch
x86__Enable_RT_also_on_32bit.patch
ARM64__Allow_to_enable_RT.patch
riscv-allow-to-enable-RT.patch

###########################################################################
# For later, not essencial
###########################################################################
# Posted
sched-rt-Don-t-try-push-tasks-if-there-are-none.patch

# sparse
0001-locking-rt-Add-sparse-annotation-PREEMPT_RT-s-sleepi.patch
0002-locking-rt-Remove-one-__cond_lock-in-RT-s-spin_trylo.patch
0003-locking-rt-Add-sparse-annotation-for-RCU.patch
0004-locking-rt-Annotate-unlock-followed-by-lock-for-spar.patch
0001-timers-Add-sparse-annotation-for-timer_sync_wait_run.patch
0002-hrtimer-Annotate-hrtimer_cpu_base_.-_expiry-for-spar.patch

# Needs discussion first.
softirq-Use-a-dedicated-thread-for-timer-wakeups.patch
rcutorture-Also-force-sched-priority-to-timersd-on-b.patch
tick-Fix-timer-storm-since-introduction-of-timersd.patch
softirq-Wake-ktimers-thread-also-in-softirq.patch

# zram
0001-zram-Replace-bit-spinlocks-with-a-spinlock_t.patch
0002-zram-Remove-ZRAM_LOCK.patch
0003-zram-Shrink-zram_table_entry-flags.patch

# Sched
0001-sched-core-Provide-a-method-to-check-if-a-task-is-PI.patch
0002-softirq-Add-function-to-preempt-serving-softirqs.patch
0003-time-Allow-to-preempt-after-a-callback.patch

# Net
netfilter-nft_counter-Use-u64_stats_t-for-statistic.patch
###########################################################################
# DRM:
###########################################################################
# https://lore.kernel.org/all/20240613102818.4056866-1-bigeasy@linutronix.de/
0001-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
0002-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
0003-drm-i915-Don-t-check-for-atomic-context-on-PREEMPT_R.patch
0004-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
0005-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
0006-drm-i915-Drop-the-irqs_disabled-check.patch
0007-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch

# Lazy preemption
PREEMPT_AUTO.patch

###########################################################################
# ARM
###########################################################################
0001-arm-Disable-jump-label-on-PREEMPT_RT.patch
ARM__enable_irq_in_translation_section_permission_fault_handlers.patch
arm-Disable-FAST_GUP-on-PREEMPT_RT-if-HIGHPTE-is-als.patch
0001-ARM-vfp-Provide-vfp_lock-for-VFP-locking.patch
0002-ARM-vfp-Use-vfp_lock-in-vfp_sync_hwstate.patch
0003-ARM-vfp-Use-vfp_lock-in-vfp_support_entry.patch
0004-ARM-vfp-Move-sending-signals-outside-of-vfp_lock-ed-.patch
ARM__Allow_to_enable_RT.patch

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

    # high-hz patch
    eapply "${FILESDIR}/highhz/0001-high-hz-0.patch"
    eapply "${FILESDIR}/highhz/0001-high-hz-1.patch"
    # eapply "${FILESDIR}/highhz/0001-high-hz-2.patch"

    # cachy patch
    # eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
    eapply "${FILESDIR}/cachy/0002-bbr3.patch"
    eapply "${FILESDIR}/cachy/0003-block.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-fixes.patch"
    # eapply "${FILESDIR}/cachy/0006-intel-pstate.patch"
    eapply "${FILESDIR}/cachy/0011-zstd.patch"

    # xanmod patch
    eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
    eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
    eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
    # eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${S}/kernel/Kconfig.hz"

    eapply_user
}
