# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="21"

inherit kernel-2 git-r3
detect_version
detect_arch
PV_BASE="$(ver_cut 1).$(ver_cut 2)"

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta alsa host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64 arm64"

# BMQ is already in +experimental. +bmq patch is from CachyOS
IUSE="naa diretta xanmod rpi experimental bore bmq clang"
REQUIRED_USE="?? ( bore bmq experimental )"

CACHY_COMMIT="7ae0737bab25246bbd393eb6424c86b42649abb1"
XANMOD_COMMIT="16b5ed95569b7b66889cf34ee233a83aac9df307"
DIRETTA_DIRECT_VER="148_1_4"
DIRETTA_ALSA_VER="148_2_4"

DIRETTA_DIRECT="${DIRETTA_DIRECT_VER%_*}"
DIRETTA_ALSA="${DIRETTA_ALSA_VER%_*}"

DIRETTA_DIRECT_P="diretta-direct-dkms-${DIRETTA_DIRECT}-${DIRETTA_DIRECT_VER##*_}-aarch64.pkg.tar.xz"
DIRETTA_ALSA_P="diretta-alsa-dkms-${DIRETTA_ALSA}-${DIRETTA_ALSA_VER##*_}-aarch64.pkg.tar.xz"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}
	bore? (
		https://raw.githubusercontent.com/CachyOS/kernel-patches/${CACHY_COMMIT}/${PV_BASE}/sched/0001-bore.patch
	)
	bmq? (
		https://raw.githubusercontent.com/CachyOS/kernel-patches/${CACHY_COMMIT}/${PV_BASE}/sched/0001-prjc.patch
	)
	xanmod? (
		https://gitlab.com/xanmod/linux-patches/-/raw/${XANMOD_COMMIT}/linux-${PV_BASE}.y-xanmod/net/tcp/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch
		https://gitlab.com/xanmod/linux-patches/-/raw/${XANMOD_COMMIT}/linux-${PV_BASE}.y-xanmod/net/tcp/0001-tcp_bbr-v3-update-TCP-bbr-congestion-control-module-.patch
	)
	diretta? (
		https://www.audio-linux.com/repo_aarch64/${DIRETTA_DIRECT_P}
		https://www.audio-linux.com/repo_aarch64/${DIRETTA_ALSA_P}
	)
	clang? (
		https://raw.githubusercontent.com/CachyOS/kernel-patches/${CACHY_COMMIT}/${PV_BASE}/misc/dkms-clang.patch
		https://raw.githubusercontent.com/CachyOS/kernel-patches/${CACHY_COMMIT}/${PV_BASE}/misc/0001-clang-polly.patch
	)
"

src_unpack() {
	if use diretta; then
		unpack ${DIRETTA_DIRECT_P}
		unpack ${DIRETTA_ALSA_P}
	fi

	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_EXCLUDE=""
	kernel-2_src_unpack
}

src_prepare() {
	# clang patch from CachyOS
	if use clang; then
		eapply "${DISTDIR}/dkms-clang.patch"
		eapply "${DISTDIR}/0001-clang-polly.patch"
	fi

	# cloudflare net patch and bbr3 from xanmod
	if use xanmod; then
		eapply "${DISTDIR}/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"
		eapply "${DISTDIR}/0001-tcp_bbr-v3-update-TCP-bbr-congestion-control-module-.patch"
	fi

	# BORE CPU Scheduler from CachyOS
	if use bore; then
		eapply ${DISTDIR}/0001-bore.patch
	fi

	# BMQ CPU Scheduler from BMQ
	if use bmq; then
		eapply ${DISTDIR}/0001-prjc.patch
	fi

	# raspberry pi
	if use rpi; then
		eapply "${FILESDIR}/rpi/rpi-${PVR}.patch"
	fi

	# naa patch
	if use naa; then
		eapply "${FILESDIR}/naa/0002-Lynx-Hilo-quirk.patch"
		eapply "${FILESDIR}/naa/0004-Adjust-USB-isochronous-packet-size.patch"
		eapply "${FILESDIR}/naa/0005-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
	fi

	# diretta alsa host driver
	if use diretta; then
		eapply "${FILESDIR}/diretta/diretta.patch"

		cp "${WORKDIR}/usr/src/diretta-direct-${DIRETTA_DIRECT}/diretta_direct.c" "${S}/sound/drivers/" || die "failed to copy diretta_direct.c"
		cp "${WORKDIR}/usr/src/diretta-direct-${DIRETTA_DIRECT}/diretta_direct.h" "${S}/sound/drivers/" || die "failed to copy diretta_direct.h"
		cp "${WORKDIR}/usr/src/diretta-alsa-${DIRETTA_ALSA}/alsa_bridge.c" "${S}/sound/drivers/" || die "failed to copy alsa_bridge.c"
		cp "${WORKDIR}/usr/src/diretta-alsa-${DIRETTA_ALSA}/alsa_bridge.h" "${S}/sound/drivers/" || die "failed to copy alsa_bridge.h"
	fi

	rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
	eapply_user
}
