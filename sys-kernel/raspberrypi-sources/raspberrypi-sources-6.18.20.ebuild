EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="20"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2 git-r3
detect_version

RT_VERSION="rt4"
MINOR_VERSION="13"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"
IUSE="naa diretta scream rt bore"

RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}.${MINOR_VERSION}-${RT_VERSION}.tar.xz
# RT_PATCH=patches-${KV_MAJOR}.${KV_MINOR}-${RT_VERSION}.tar.xz
RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${KV_MAJOR}.${KV_MINOR}/older/${RT_PATCH}"

EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
EGIT_BRANCH="rpi-${KV_MAJOR}.${KV_MINOR}.y"
EGIT_CLONE_TYPE="shallow"

SCREAM_EGIT_REPO_URI="https://github.com/igor63r/screamalsa.git"
SCREAM_S="${WORKDIR}/screamalsa"

SRC_URI="${GENPATCHES_URI} ${RT_URI}"

S="${WORKDIR}/linux-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}-raspberrypi"
EXTRAVERSION="-networkaudio"

src_unpack() {
    unpack "${RT_PATCH}"
    mv "${WORKDIR}"/patches "${WORKDIR}"/rtpatch

    git-r3_src_unpack
    mv "${WORKDIR}/${PF}" "${S}"

    if use scream; then
        EGIT_REPO_URI="${SCREAM_EGIT_REPO_URI}" \
        EGIT_BRANCH= \
        EGIT_CHECKOUT_DIR="${SCREAM_S}" \
        git-r3_fetch

        EGIT_REPO_URI="${SCREAM_EGIT_REPO_URI}" \
        EGIT_BRANCH= \
        EGIT_CHECKOUT_DIR="${SCREAM_S}" \
        git-r3_checkout

        [[ -f "${SCREAM_S}/snd-screamalsa.c" ]] || die "screamalsa source file missing"
        [[ -f "${SCREAM_S}/Kconfig" ]] || die "screamalsa Kconfig missing"
        [[ -f "${SCREAM_S}/Makefile" ]] || die "screamalsa Makefile missing"
    fi

    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.base.tar.xz
    unpack genpatches-${KV_MAJOR}.${KV_MINOR}-${K_GENPATCHES_VER}.extras.tar.xz

    rm -rfv "${WORKDIR}"/10*.patch
    rm -rfv "${S}/.git"

    mkdir "${WORKDIR}"/genpatch
    mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/
    unpack_set_extraversion
}

src_prepare() {
    # genpatch
    eapply "${WORKDIR}"/genpatch/*.patch

    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0001-Lynx-Hilo-quirk.patch"
        eapply "${FILESDIR}/naa/0002-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0003-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0004-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
        eapply "${FILESDIR}/naa/0001-DSD-patches-unstaged.patch"
        # eapply "${FILESDIR}/naa/0001-Try-different-order-on-mode-select-on-ITF-interface.patch"
        eapply "${FILESDIR}/naa/0002-Do-not-expose-PCM-and-DSD-on-same-altsetting-unless-.patch"
    fi

    eapply "${FILESDIR}/cachy/0003-bbr3.patch"
    eapply "${FILESDIR}/cachy/0004-cachy.patch"
    eapply "${FILESDIR}/cachy/0005-crypto.patch"
    eapply "${FILESDIR}/cachy/0006-fixes.patch"

    # bore scheduler
    if use bore; then
        eapply "${FILESDIR}/sched/0001-bore-cachy.patch"
    fi

    # diretta alsa host driver
    if use diretta; then
        eapply "${FILESDIR}/diretta/diretta.patch"
        eapply "${FILESDIR}/diretta/diretta_2025.11.29.patch"
    fi

	# screamalsa virtual ALSA driver
	if use scream; then
		local drivers_kconfig="${S}/sound/drivers/Kconfig"
		local drivers_makefile="${S}/sound/drivers/Makefile"
		local scream_kconfig_tmp="${T}/sound-drivers.Kconfig.scream"
		local scream_makefile_tmp="${T}/sound-drivers.Makefile.scream"
		local scream_makefile_line='obj-$(CONFIG_SND_SCREAMALSA) += snd-screamalsa.o'

		cp "${SCREAM_S}/snd-screamalsa.c" "${S}/sound/drivers/" || die "failed to copy snd-screamalsa.c"

		[[ -r "${drivers_kconfig}" ]] || die "sound/drivers/Kconfig missing or unreadable"
		[[ -r "${drivers_makefile}" ]] || die "sound/drivers/Makefile missing or unreadable"

		if grep -q '^config SND_SCREAMALSA$' "${drivers_kconfig}"; then
			:
        elif [[ $? -eq 1 ]]; then
            cp "${drivers_kconfig}" "${scream_kconfig_tmp}" || die "failed to stage sound/drivers/Kconfig update"
            {
                printf '\n'
                cat "${SCREAM_S}/Kconfig"
            } >> "${scream_kconfig_tmp}" || die "failed to stage sound/drivers/Kconfig update"
            mv "${scream_kconfig_tmp}" "${drivers_kconfig}" || die "failed to update sound/drivers/Kconfig"
		else
			die "failed to read sound/drivers/Kconfig"
		fi

		if grep -qxF "${scream_makefile_line}" "${drivers_makefile}"; then
			:
		elif [[ $? -eq 1 ]]; then
			cp "${drivers_makefile}" "${scream_makefile_tmp}" || die "failed to stage sound/drivers/Makefile update"
			printf '\n%s\n' "${scream_makefile_line}" >> "${scream_makefile_tmp}" || die "failed to stage sound/drivers/Makefile update"
			mv "${scream_makefile_tmp}" "${drivers_makefile}" || die "failed to update sound/drivers/Makefile"
		else
			die "failed to read sound/drivers/Makefile"
		fi
	fi

    # cloudflare patch
    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    #if use mtu9k; then
    #    eapply "${FILESDIR}/mtu9k/setting-9000-mtu-jumbo-frames-on-raspberry-pi-os.patch"
    #fi

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
#Reapply-serial-8250-Switch-to-nbcon-console.patch
#Reapply-serial-8250-Revert-drop-lockdep-annotation-f.patch

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
#0001-drm-i915-Use-preempt_disable-enable_rt-where-recomme.patch
#0002-drm-i915-Don-t-disable-interrupts-on-PREEMPT_RT-duri.patch
#0004-drm-i915-Disable-tracing-points-on-PREEMPT_RT.patch
#0005-drm-i915-gt-Use-spin_lock_irq-instead-of-local_irq_d.patch
#0006-drm-i915-Drop-the-irqs_disabled-check.patch
#0007-drm-i915-guc-Consider-also-RCU-depth-in-busy-loop.patch
#drm-i915-Consider-RCU-read-section-as-atomic.patch
#0008-Revert-drm-i915-Depend-on-PREEMPT_RT.patch

###########################################################################
# ARM
###########################################################################
0001-ARM-mm-fault-Move-harden_branch_predictor-before-int.patch
0002-ARM-mm-fault-Enable-interrupts-before-invoking-__do_.patch
0003-ARM-Disable-jump-label-on-PREEMPT_RT.patch
0005-ARM-Allow-to-enable-RT.patch

###########################################################################
# POWERPC
###########################################################################
#powerpc_pseries_iommu__Use_a_locallock_instead_local_irq_save.patch
#powerpc-pseries-Select-the-generic-memory-allocator.patch
#powerpc_kvm__Disable_in-kernel_MPIC_emulation_for_PREEMPT_RT.patch
#powerpc_stackprotector__work_around_stack-guard_init_from_atomic.patch
#POWERPC__Allow_to_enable_RT.patch

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
