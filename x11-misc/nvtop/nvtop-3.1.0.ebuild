# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="AMD and NVIDIA GPUs htop like monitoring tool"
HOMEPAGE="https://github.com/Syllo/nvtop"

SRC_URI="https://github.com/Syllo/nvtop/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

LICENSE="GPL-3"
SLOT="0"

IUSE="video_cards_amdgpu video_cards_intel video_cards_nvidia"
REQUIRED_USE="
	|| (
		video_cards_amdgpu
		video_cards_intel
		video_cards_nvidia
	)
"
RESTRICT=""

DEPEND="
	sys-libs/ncurses:=
	virtual/libudev:=
	video_cards_amdgpu? (
		x11-libs/libdrm[video_cards_amdgpu]
	)
	video_cards_intel? (
		x11-libs/libdrm[video_cards_intel]
	)
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers
	)
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/nvtop-3.1.0-fix-tests.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
		-DAMDGPU_SUPPORT=$(usex video_cards_amdgpu)
		-DINTEL_SUPPORT=$(usex video_cards_intel)
		-DNVIDIA_SUPPORT=$(usex video_cards_nvidia)
		-DAPPLE_SUPPORT=OFF
		-DASCEND_SUPPORT=OFF
		-DMSM_SUPPORT=OFF
		-DPANFROST_SUPPORT=OFF
		-DPANTHOR_SUPPORT=off
	)
	cmake_src_configure
}
