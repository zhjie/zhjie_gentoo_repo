# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="10"
K_EXP_GENPATCHES_NOUSE="1"
K_NODRYRUN="1"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa rt"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi
	UNIPATCH_LIST+=" ${FILESDIR}/cachy/all/0001-cachyos-base-all.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-high-hz.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-lrng.patch"
	if use rt; then
		UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-rt.patch"
	else
		UNIPATCH_LIST+=" ${FILESDIR}/cachy/sched/0001-prjc-cachy.patch"
	fi
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
