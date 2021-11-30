# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils git-r3

DESCRIPTION="NVIDIA GPUs htop like monitoring tool"
HOMEPAGE="https://github.com/Syllo/nvtop"
LICENSE="GPL-3"
SLOT="0"
IUSE="unicode"

RDEPEND="
	sys-libs/ncurses
	dev-vcs/git
	x11-drivers/nvidia-drivers
"

DEPEND="
	dev-util/cmake
	${RDEPEND}
"

BUILD_DIR="${WORKDIR}/build"

EGIT_REPO_URI="https://github.com/Syllo/${PN}.git"

CMAKE_CONF="
	unicode? ( -DCURSES_NEED_WIDE=TRUE )
"

src_prepare() {
	default
	cmake-utils_src_prepare
	mkdir -p "${BUILD_DIR}/include"
	cp -f "${FILESDIR}/nvml.h" "${BUILD_DIR}/include/nvml.h"
	cp -f "${FILESDIR}/FindCurses.cmake" "${WORKDIR}/${P}/cmake/modules/FindCurses.cmake"
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		${CMAKE_CONF}
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
