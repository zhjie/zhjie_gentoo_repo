# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="14"
K_EXP_GENPATCHES_NOUSE="1"

HOMEPAGE="https://github.com/CachyOS/linux-cachyos"
LICENSE+="GPL-3.0"
KEYWORDS="amd64"
IUSE=""

inherit kernel-2
detect_version

DESCRIPTION="CachyOS Kernel sources with Gentoo patchset and naa patches"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

KV_FULL="${KV_FULL}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
        UNIPATCH_EXCLUDE=""
	kernel-2_src_unpack
}

src_prepare() {
	# high-hz patch
	#eapply "${FILESDIR}/0001-high-hz.patch"
	#eapply "${FILESDIR}/0001-high-hz-1.patch"
	#eapply "${FILESDIR}/0001-high-hz-2.patch"

	# cachy patch
	eapply "${FILESDIR}/all/0001-cachyos-base-all.patch"
	eapply "${FILESDIR}/sched/0001-bore-cachy.patch"

        eapply_user
}
