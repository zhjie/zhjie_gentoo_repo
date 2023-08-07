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
IUSE="naa"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""

        if use naa; then
	        UNIPATCH_LIST+=" ${FILESDIR}/naa/00*.patch"
        fi

        UNIPATCH_LIST+=" ${FILESDIR}/xanmod/net/tcp/000*.patch"
#	UNIPATCH_LIST+=" ${FILESDIR}/xanmod/futex/0001-futex-Add-entry-point-for-FUTEX_WAIT_MULTIPLE-opcode.patch"

	UNIPATCH_LIST+=" ${FILESDIR}/cachy/all/0001-cachyos-base-all.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-high-hz.patch"
	UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-lrng.patch"
	UNIPATCH_LIST+=" ${FILESDIR}/cachy/sched/0001-prjc.patch"

	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
