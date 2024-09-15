# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.10"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="30dcc7ec2009395c3e671db6ef0ea4b3cc10f467"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="13"
K_EXP_GENPATCHES_NOUSE="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="rt14"
MINOR_VERSION="2"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version
EXTRAVERSION="-networkaudio-rt${RT_VERSION}"

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}
    https://cdn.kernel.org/pub/linux/kernel/projects/rt/${K_BASE_VER}/older/patches-${K_BASE_VER}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
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

    unpack patches-${K_BASE_VER}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
    # unpack patches-${K_BASE_VER}-${RT_VERSION}.tar.xz

    mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch
    echo "${EXTRAVERSION}"
    unpack_set_extraversion
}

src_prepare() {
    local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################

###########################################################################
# Posted
###########################################################################

# Frederick's
0001-task_work-s-task_work_cancel-task_work_cancel_func.patch
0002-task_work-Introduce-task_work_cancel-again.patch
0003-perf-Fix-event-leak-upon-exit.patch
0004-perf-Fix-event-leak-upon-exec-and-file-release.patch

# perf, sigtrap, v5
0001-perf-Move-irq_work_queue-where-the-event-is-prepared.patch
0002-task_work-Add-TWA_NMI_CURRENT-as-an-additional-notif.patch
0003-perf-Enqueue-SIGTRAP-always-via-task_work.patch
0004-perf-Shrink-the-size-of-the-recursion-counter.patch
0005-perf-Move-swevent_htable-recursion-into-task_struct.patch
0006-perf-Don-t-disable-preemption-in-perf_pending_task.patch
0007-perf-Split-__perf_pending_irq-out-of-perf_pending_ir.patch
task_work-make-TWA_NMI_CURRENT-handling-conditional-.patch

# locking.
drm-ttm-tests-Let-ttm_bo_test-consider-different-ww_.patch

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
0011-nbcon-Add-API-to-acquire-context-for-non-printing-op.patch
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
0030-printk-Rename-console_replay_all-and-update-context.patch
0031-printk-nbcon-Introduce-printing-kthreads.patch
0032-printk-Atomic-print-in-printk-context-on-shutdown.patch
0033-printk-nbcon-Fix-nbcon_cpu_emergency_flush-when-pree.patch
0034-printk-nbcon-Add-context-to-console_is_usable.patch
0035-printk-nbcon-Add-printer-thread-wakeups.patch
0036-printk-nbcon-Stop-threads-on-shutdown-reboot.patch
0037-printk-nbcon-Start-printing-threads.patch
0038-printk-Provide-helper-for-message-prepending.patch
0039-printk-nbcon-Show-replay-message-on-takeover.patch
0040-printk-Add-kthread-for-all-legacy-consoles.patch
0041-proc-consoles-Add-notation-to-c_start-c_stop.patch
0042-proc-Add-nbcon-support-for-proc-consoles.patch
0043-tty-sysfs-Add-nbcon-support-for-active.patch
0044-printk-Provide-threadprintk-boot-argument.patch
0045-printk-Avoid-false-positive-lockdep-report-for-legac.patch
0046-printk-nbcon-Add-function-for-printers-to-reacquire-.patch
0047-serial-8250-Switch-to-nbcon-console.patch
0048-serial-8250-Revert-drop-lockdep-annotation-from-seri.patch
#
prinkt-nbcon-Add-a-scheduling-point-to-nbcon_kthread.patch

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

# BH series
0001-locking-local_lock-Introduce-guard-definition-for-lo.patch
0002-locking-local_lock-Add-local-nested-BH-locking-infra.patch
0003-net-Use-__napi_alloc_frag_align-instead-of-open-codi.patch
0004-net-Use-nested-BH-locking-for-napi_alloc_cache.patch
0005-net-tcp_sigpool-Use-nested-BH-locking-for-sigpool_sc.patch
0006-net-ipv4-Use-nested-BH-locking-for-ipv4_tcp_sk.patch
0007-netfilter-br_netfilter-Use-nested-BH-locking-for-brn.patch
0008-net-softnet_data-Make-xmit-per-task.patch
0009-dev-Remove-PREEMPT_RT-ifdefs-from-backlog_lock.patch
0010-dev-Use-nested-BH-locking-for-softnet_data.process_q.patch
0011-lwt-Don-t-disable-migration-prio-invoking-BPF.patch
0012-seg6-Use-nested-BH-locking-for-seg6_bpf_srh_states.patch
0013-net-Use-nested-BH-locking-for-bpf_scratchpad.patch
0014-net-Reference-bpf_redirect_info-via-task_struct-on-P.patch
0015-net-Move-per-CPU-flush-lists-to-bpf_net_context-on-P.patch
# optimisation + fixes
0001-net-Remove-task_struct-bpf_net_context-init-on-fork.patch
0002-net-Optimize-xdp_do_flush-with-bpf_net_context-infos.patch
0003-net-Move-flush-list-retrieval-to-where-it-is-used.patch
tun-Assign-missing-bpf_net_context.patch
tun-Add-missing-bpf_net_ctx_clear-in-do_xdp_generic.patch
bpf-Remove-tst_run-from-lwt_seg6local_prog_ops.patch
# tw_timer
0001-net-tcp-dccp-prepare-for-tw_timer-un-pinning.patch
0002-net-tcp-un-pin-the-tw_timer.patch
0003-tcp-move-inet_twsk_schedule-helper-out-of-header.patch

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
    eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
    eapply "${FILESDIR}/cachy/0002-bbr3.patch"
    eapply "${FILESDIR}/cachy/0003-block.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-crypto.patch"
    eapply "${FILESDIR}/cachy/0006-fixes.patch"
    eapply "${FILESDIR}/cachy/0011-zstd.patch"

    # xanmod patch
    eapply "${FILESDIR}/xanmod/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
    eapply "${FILESDIR}/xanmod/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
    eapply "${FILESDIR}/xanmod/intel/0003-locking-rwsem-spin-faster.patch"
    # eapply "${FILESDIR}/xanmod/intel/0004-drivers-initialize-ata-before-graphics.patch"

    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    # eapply "${FILESDIR}/xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions-v.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0006-XANMOD-sched-core-Increase-number-of-tasks-to-iterat.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0007-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0011-XANMOD-blk-wbt-Set-wbt_default_latency_nsec-to-2msec.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0012-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0013-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0014-XANMOD-mm-Raise-max_map_count-default-value.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0015-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
    # eapply "${FILESDIR}/xanmod/xanmod/0016-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0017-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
    eapply "${FILESDIR}/xanmod/xanmod/0018-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"

    cp -vf "${FILESDIR}/highhz/Kconfig.hz" "${WORKDIR}/linux-${K_BASE_VER}-raspberrypi-rt/kernel/Kconfig.hz"
    eapply_user
}
