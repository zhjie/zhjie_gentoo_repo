# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="21"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"

IUSE="naa scream diretta highhz bore rpi"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

SCREAM_EGIT_REPO_URI="https://github.com/igor63r/screamalsa.git"
SCREAM_S="${WORKDIR}/screamalsa"

src_unpack() {
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

    UNIPATCH_LIST_DEFAULT=""
    UNIPATCH_EXCLUDE=""
    kernel-2_src_unpack
}

src_prepare() {

    # cloudflare patch
    eapply "${FILESDIR}/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    if use rpi; then
        eapply "${FILESDIR}/rpi/rpi-6.18.21.patch"
    fi

    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0002-Lynx-Hilo-quirk.patch"
        eapply "${FILESDIR}/naa/0003-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0004-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0005-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
        eapply "${FILESDIR}/naa/0002-Do-not-expose-PCM-and-DSD-on-same-altsetting-unless-.patch"
    fi

    if use bore; then
        eapply "${FILESDIR}/sched/0001-bore-cachy.patch"
    fi

    # highhz patch
    if use highhz; then
        eapply "${FILESDIR}/hz2k/0001-high-hz-0.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-1.patch"
        eapply "${FILESDIR}/hz2k/0001-high-hz-2.patch"
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

    rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
    eapply_user
}
