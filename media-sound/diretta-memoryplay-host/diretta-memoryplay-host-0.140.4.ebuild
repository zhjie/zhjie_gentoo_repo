# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta MemoryPlay Host"
HOMEPAGE="https://www.diretta.link/preview/"

SRC_URI="https://www.diretta.link/preview/MemoryPlayHostLinux.tar.zst"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="CDDL"
IUSE="cpu_flags_x86_avx2 cpu_flags_x86_avx512"
BDEPEND=""

src_unpack() {
	_unpacker MemoryPlayHostLinux.tar.zst
	mkdir -pv "${WORKDIR}"/"${P}"/"${PN}"

	if use cpu_flags_x86_avx2; then
		mv -v MemoryPlay/MemoryPlayHost_gcc14_x64_v3 "${WORKDIR}"/"${P}"/"${PN}"/MemoryPlayHost
	fi
	if use cpu_flags_x86_avx512; then
		mv -v MemoryPlay/MemoryPlayHost_gcc14_x64_v4 "${WORKDIR}"/"${P}"/"${PN}"/MemoryPlayHost
	fi
	if use !cpu_flags_x86_avx2 and use !cpu_flags_x86_avx512; then
		mv -v MemoryPlay/MemoryPlayHost_gcc14_x64_v2 "${WORKDIR}"/"${P}"/"${PN}"/MemoryPlayHost
	fi
	mv -v MemoryPlay/memoryplayhost_setting.inf "${WORKDIR}"/"${P}"/"${PN}"
}

src_install() {
	find .
	insinto "/opt/"
	insopts -m755
	doins -r *
	newinitd "${FILESDIR}/diretta-memoryplay-host.init.d" "diretta-memoryplay-host"
}
