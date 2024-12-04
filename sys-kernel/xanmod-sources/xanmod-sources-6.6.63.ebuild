# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="71"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="XanMod Kernel with Gentoo patchset"
HOMEPAGE="https://gitlab.com/xanmod/linux-patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
KEYWORDS="amd64"

src_prepare() {
    # bmq
    eapply "${FILESDIR}/bmq/sched-prjc-20231205-v6.6-r1.patch"
    eapply "${FILESDIR}/bmq/sched-prjc-20231228-implement-missing-CPU-files-stubs-for-cgroups-v1-and-v2.patch"

    # intel
    eapply "${FILESDIR}/intel/0001-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
    eapply "${FILESDIR}/intel/0002-firmware-Enable-stateless-firmware-loading.patch"
    eapply "${FILESDIR}/intel/0003-locking-rwsem-spin-faster.patch"
    eapply "${FILESDIR}/intel/0004-drivers-initialize-ata-before-graphics.patch"

    # kconfig
    eapply "${FILESDIR}/kconfig/0001-x86-kconfig-more-uarches-for-kernel-5.17-xm_rev5.patch"
    eapply "${FILESDIR}/kconfig/0002-XANMOD-Makefile-Move-ARM-and-x86-instruction-set-sel.patch"

    # bbr3
    eapply "${FILESDIR}/net/tcp/bbr3/0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch"
    eapply "${FILESDIR}/net/tcp/bbr3/0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch"

    # cloudflare
    eapply "${FILESDIR}/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    # xanmod
    eapply "${FILESDIR}/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
    eapply "${FILESDIR}/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
    eapply "${FILESDIR}/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions-6.patch"
    eapply "${FILESDIR}/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
    # eapply "${FILESDIR}/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
    eapply "${FILESDIR}/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
    eapply "${FILESDIR}/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
    eapply "${FILESDIR}/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
    eapply "${FILESDIR}/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
    eapply "${FILESDIR}/xanmod/0010-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
    eapply "${FILESDIR}/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
    eapply "${FILESDIR}/xanmod/0012-XANMOD-mm-Raise-max_map_count-default-value.patch"
    eapply "${FILESDIR}/xanmod/0013-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
    eapply "${FILESDIR}/xanmod/0014-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
    eapply "${FILESDIR}/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
    eapply "${FILESDIR}/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"

    eapply_user
}
