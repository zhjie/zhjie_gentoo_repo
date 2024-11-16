# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Linux Diretta MemoryPlay Controller"
HOMEPAGE="https://www.diretta.link/preview/"

SRC_URI="https://www.diretta.link/preview/MemoryPlayControllerSDK.tar.zst"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="CDDL"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512"
DEPEND="media-libs/flac[cxx,include]"

src_unpack() {
	_unpacker MemoryPlayControllerSDK.tar.zst
	mv MemoryPlayControllerSDK "${WORKDIR}"/"${P}"

	if use cpu_flags_x86_avx2; then
		cp -v "${WORKDIR}"/"${P}"/libACQUA_x64-linux-14v2.a "${WORKDIR}"/"${P}"/libACQUA.a
		cp -v "${WORKDIR}"/"${P}"/libFind_x64-linux-14v2.a "${WORKDIR}"/"${P}"/libFind.a
	fi
	if use cpu_flags_x86_avx512; then
		mv -v MemoryPlay/MemoryPlayHost_gcc14_x64_v4 "${WORKDIR}"/"${P}"/"${PN}"/MemoryPlayHost
	fi
	if use !cpu_flags_x86_avx2 and use !cpu_flags_x86_avx512; then
		mv -v MemoryPlay/MemoryPlayHost_gcc14_x64_v2 "${WORKDIR}"/"${P}"/"${PN}"/MemoryPlayHost
	fi
}

src_configure() {
	find . |grep Makefile
	sed -i "s/static/no-pie/g" Makefile
}

src_install() {
	dobin MemoryPlayController
}
