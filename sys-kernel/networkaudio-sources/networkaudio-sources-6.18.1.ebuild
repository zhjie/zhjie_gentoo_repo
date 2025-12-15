# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="2"
K_EXP_GENPATCHES_NOUSE="1"

RT_VERSION="rc4-rt3"
MINOR_VERSION="0"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa diretta highhz rt amd"

# RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}-${RT_VERSION}.tar.xz
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
    fi

    if use amd; then
        eapply "${FILESDIR}/cachy/0001-amd-pstate.patch"
    fi

    eapply "${FILESDIR}/cachy/0003-autofdo.patch"
    eapply "${FILESDIR}/cachy/0004-bbr3.patch"
    eapply "${FILESDIR}/cachy/0005-block.patch"
    eapply "${FILESDIR}/cachy/0006-cachy.patch"
    eapply "${FILESDIR}/cachy/0007-crypto.patch"
    eapply "${FILESDIR}/cachy/0008-fixes.patch"

    # highhz patch
    if use highhz; then
        eapply "${FILESDIR}/hz2k/0001-high-hz-0.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-1.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-2.patch"
    fi

    # diretta alsa host driver
    if use diretta; then
        eapply "${FILESDIR}/diretta/diretta_alsa_host.patch"
        eapply "${FILESDIR}/diretta/diretta_alsa_host_2025.11.26.patch"
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

###########################################################################
# Posted
###########################################################################

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
0004-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
0005-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
0006-drm-i915-Drop-the-irqs_disabled-check.patch
0007-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
drm-i915-Consider-RCU-read-section-as-atomic.patch
0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# ARM
###########################################################################
0001-ARM-mm-fault-Move-harden_branch_predictor-before-int.patch
0002-ARM-mm-fault-Enable-interrupts-before-invoking-__do_.patch
0003-ARM-Disable-jump-label-on-PREEMPT_RT.patch
0004-ARM-Disable-HIGHPTE-on-PREEMPT_RT-kernels.patch
0005-ARM-Allow-to-enable-RT.patch

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
