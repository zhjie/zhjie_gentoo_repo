# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="10"

HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="+experimental naa"

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
#        UNIPATCH_LIST+=" ${FILESDIR}/cachy/00*.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/cachy/misc/0001-high-hz.patch"
	UNIPATCH_LIST+=" ${FILESDIR}/xanmod/0010-XANMOD-kconfig-add-500Hz-timer-interrupt-kernel-conf.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/futex/00*.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/net/bbr2/00*.patch"
        UNIPATCH_LIST+=" ${FILESDIR}/net/tcp/00*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
