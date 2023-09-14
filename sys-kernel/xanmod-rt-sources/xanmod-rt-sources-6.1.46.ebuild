# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_EXP_GENPATCHES_NOUSE="1"
K_GENPATCHES_VER="53"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
RT_VERSION="13"
XANMOD_VERSION="1"
XANMOD_URI="https://master.dl.sourceforge.net/project/xanmod/releases/rt/"
# K_NODRYRUN="1"

HOMEPAGE="https://xanmod.org"
LICENSE+=" CDDL"
KEYWORDS="~amd64 ~arm64 ~arm"
IUSE="+naa"

inherit kernel-2
detect_version

DESCRIPTION="XanMod Kernel sources including the Gentoo patchset - Current Stable (CURRENT) branch"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${XANMOD_URI}/${OKV}-rt${RT_VERSION}-xanmod${XANMOD_VERSION}/patch-${OKV}-rt${RT_VERSION}-xanmod${XANMOD_VERSION}.xz
	${GENPATCHES_URI}
"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_LIST+="${DISTDIR}/patch-${OKV}-rt${RT_VERSION}-xanmod${XANMOD_VERSION}.xz"
        if use naa; then
                UNIPATCH_LIST+=" ${FILESDIR}/000*.patch"
        fi
#        UNIPATCH_LIST+=" ${FILESDIR}/100*.patch"
	UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
