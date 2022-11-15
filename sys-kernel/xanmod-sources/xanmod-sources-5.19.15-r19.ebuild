# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_EXP_GENPATCHES_NOUSE="1"
K_GENPATCHES_VER="19"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
XANMOD_VERSION="1"
XANMOD_URI="https://github.com/xanmod/linux/releases/download/"
K_NODRYRUN="1"

HOMEPAGE="https://xanmod.org"
LICENSE+=" CDDL"
KEYWORDS="~amd64"
IUSE="naa"

RDEPEND="
	!sys-kernel/xanmod-rt-sources
	!sys-kernel/xanmod-tt-sources
"

inherit kernel-2
detect_version

DESCRIPTION="XanMod Kernel sources including the Gentoo patchset - Current Stable (CURRENT) branch"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${GENPATCHES_URI}
	${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz
"

# excluding all minor kernel revision patches; XanMod will take care of that
UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"

src_unpack() {
	UNIPATCH_LIST+="${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz "
        if use naa; then
                UNIPATCH_LIST+=" ${FILESDIR}/*.patch"
        fi
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
