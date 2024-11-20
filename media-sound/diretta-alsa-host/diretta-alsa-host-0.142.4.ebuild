# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta Alsa Host"
HOMEPAGE="https://www.diretta.link/preview/"

DIRETTA_ALSA_HOST="DirettaSalsaHost.tar.zst"
SRC_URI="https://www.diretta.link/preview/DirettaSalsaHost.tar.zst"

KEYWORDS="~amd64 ~arm64"
SLOT="0"
LICENSE="CDDL"
IUSE="cpu_flags_x86_avx2 cpu_flags_x86_avx512"

BDEPEND="|| ( sys-kernel/networkaudio-sources[diretta] sys-kernel/networkaudio-rt-sources[diretta] sys-kernel/raspberrypi-sources[diretta] )"

src_unpack() {
        _unpacker "${DIRETTA_ALSA_HOST}"
	mkdir -p "${WORKDIR}/${P}/opt"

	mv ./DirettaSalsaHost/setting.inf "${WORKDIR}/${P}"
	if use amd64; then
		if use cpu_flags_x86_avx512; then
			mv ./DirettaSalsaHost/ssyncAlsa_gcc14_x64_v4 "${WORKDIR}/${P}/ssyncAlsa"
		else
			if use cpu_flags_x86_avx2; then
				mv ./DirettaSalsaHost/ssyncAlsa_gcc14_x64_v3 "${WORKDIR}/${P}/ssyncAlsa"
			else
				mv ./DirettaSalsaHost/ssyncAlsa_gcc14_x64_v2 "${WORKDIR}/${P}/ssyncAlsa"
			fi
		fi
	fi
	if use arm64; then
		mv ./DirettaSalsaHost/ssyncAlsa_gcc14_arm64_v81A16k "${WORKDIR}/${P}/ssyncAlsa_gcc14_arm64_v81A16k"
		mv ./DirettaSalsaHost/ssyncAlsa_gcc14_arm64_v80A4k "${WORKDIR}/${P}/ssyncAlsa_gcc14_arm64_v80A4k"
	fi
}

src_install() {
	insinto "/opt/${PN}/"
	insopts -m755
	doins *
	doins "${FILESDIR}/alsa_host.sh"
	newinitd "${FILESDIR}/diretta-alsa-host.init.d" "diretta-alsa-host"
}
