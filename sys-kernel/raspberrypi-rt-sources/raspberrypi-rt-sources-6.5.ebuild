# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.5"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="6"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

RT_URI="https://cdn.kernel.org/pub/linux/kernel/projects/rt"
RT_VERSION="6"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}
	${RT_URI}/${K_BASE_VER}/patch-${K_BASE_VER}-rt${RT_VERSION}.patch.xz
"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.6-r4"

EXTRAVERSION="-raspberrypi-rt"
S="${WORKDIR}/linux-${K_BASE_VER}${EXTRAVERSION}"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz
	unpack patch-${K_BASE_VER}-rt${RT_VERSION}.patch.xz

	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${S}/.git"
	mv patch-${K_BASE_VER}-rt${RT_VERSION}.patch patch-${K_BASE_VER}-rt${RT_VERSION}
}

src_prepare() {
	cp -v "${FILESDIR}/${K_BASE_VER}-networkaudio-rt" ${K_BASE_VER}-networkaudio-rt

	# genpatch
	eapply "${WORKDIR}"/*.patch

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch and rt patch
	if use cachy; then
	        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
	        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"
		eapply "${FILESDIR}/cachy/6.5/misc/0001-rt.patch"
	        eapply "${FILESDIR}/rt-arm-arm64-${K_BASE_VER}.patch"
	else
		eapply "${WORKDIR}/patch-${K_BASE_VER}-rt${RT_VERSION}"
	fi

	# xanmod patch
	if use xanmod; then
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0006-locking-rwsem-spin-faster.patch"

		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0012-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0017-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"
	fi

        eapply_user
}
