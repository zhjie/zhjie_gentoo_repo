# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="10"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa"

inherit kernel-2
detect_version
EXTRAVERSION="-networkaudio-rt"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

KV_FULL="${KV_FULL}-rt"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""

        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi

	kernel-2_src_unpack
}

src_prepare() {
	# cachy patch
        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
        eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"

	# rt patch
        eapply "${FILESDIR}/cachy/6.5/misc/0001-rt.patch"

	# xanmod patch
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0003-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0006-locking-rwsem-spin-faster.patch"

        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0012-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0017-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"

        eapply_user
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
