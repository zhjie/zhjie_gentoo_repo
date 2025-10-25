# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="7"
K_EXP_GENPATCHES_NOUSE="1"

RT_VERSION="rt7"
MINOR_VERSION="5"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa diretta highhz rt"

RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
# RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}-${RT_VERSION}.tar.xz
RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/${RT_PATCH}"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${RT_URI}"

src_unpack() {
    unpack "${RT_PATCH}"
    mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch

    UNIPATCH_LIST_DEFAULT=""
    UNIPATCH_EXCLUDE=""
    kernel-2_src_unpack
}

src_prepare() {
    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0001-Miscellaneous-sample-rate-extensions.patch"
        eapply "${FILESDIR}/naa/0002-Lynx-Hilo-quirk.patch"
        eapply "${FILESDIR}/naa/0003-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0004-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0005-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
        eapply "${FILESDIR}/naa/0009-DSD-patches-unstaged.patch"
    fi

    eapply "${FILESDIR}/cachy/0002-bbr3.patch"
    eapply "${FILESDIR}/cachy/0003-block.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-fixes.patch"

    # highhz patch
    if use highhz; then
        eapply "${FILESDIR}/hz2k/0001-high-hz-0.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-1.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-2.patch"
    fi

    # diretta alsa host driver
    if use diretta; then
        eapply "${FILESDIR}/diretta/diretta_alsa_host.patch"
        eapply "${FILESDIR}/diretta/diretta_alsa_host_2025.04.25.patch"
    fi

    # cloudflare patch
    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    if use rt; then
    # rt patch
    local p rt_patches=(
# Applied upstream

###########################################################################
# Posted and applied
###########################################################################
# Netfilter backports for pipapo + BH-locking
0001-netfilter-ctnetlink-remove-refcounting-in-dying-list.patch
0002-netfilter-nft_set_pipapo_avx2-Drop-the-comment-regar.patch
0003-netfilter-nft_set_pipapo_avx2-split-lookup-function-.patch
0004-netfilter-nft_set_pipapo-use-avx2-algorithm-for-inse.patch
0005-netfilter-nft_set_pipapo-Store-real-pointer-adjust-l.patch
0006-netfilter-nft_set_pipapo-Use-nested-BH-locking-for-n.patch
netfilter-nft_set_pipapo-use-0-genmask-for-packetpat.patch
netfilter-nft_set_pipapo_avx2-fix-skip-of-expired-en.patch

###########################################################################
# Posted
###########################################################################
# Final bits for BH-lock removal
0001-workqueue-Provide-a-handshake-for-canceling-BH-worke.patch
0002-softirq-Provide-a-handshake-for-canceling-tasklets-v.patch
0003-softirq-Allow-to-drop-the-softirq-BKL-lock-on-PREEMP.patch
net-gro_cells-Use-nested-BH-locking-for-gro_cell.patch

###########################################################################
# John's printk queue
###########################################################################
# Atomic console
Reapply-serial-8250-Switch-to-nbcon-console.patch
Reapply-serial-8250-Revert-drop-lockdep-annotation-f.patch

###########################################################################
# Post
###########################################################################

###########################################################################
# For later, not essencial
###########################################################################

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
drm-i915-Consider-RCU-read-section-as-atomic.patch
0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# ARM
###########################################################################
0001-arm-Disable-jump-label-on-PREEMPT_RT.patch
ARM__enable_irq_in_translation_section_permission_fault_handlers.patch
arm-Disable-FAST_GUP-on-PREEMPT_RT-if-HIGHPTE-is-als.patch
ARM__Allow_to_enable_RT.patch

###########################################################################
# POWERPC
###########################################################################
powerpc_pseries_iommu__Use_a_locallock_instead_local_irq_save.patch
powerpc-pseries-Select-the-generic-memory-allocator.patch
powerpc_kvm__Disable_in-kernel_MPIC_emulation_for_PREEMPT_RT.patch
powerpc_stackprotector__work_around_stack-guard_init_from_atomic.patch
POWERPC__Allow_to_enable_RT.patch

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

    fi

    rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
    eapply_user
}
