# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A qt6 qml style provider for hypr* apps."
HOMEPAGE="https://github.com/hyprwm/hyprland-qt-support"

if [[ "${PV}" = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/${PN}-${PV}"

	KEYWORDS="amd64"
fi

LICENSE="BSD"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
        local mycmakeargs=(
                -DBUILD_TESTING=OFF
		-DCMAKE_BUILD_TYPE:STRING=Release
		-DCMAKE_INSTALL_PREFIX:PATH=/usr
		-DINSTALL_QML_PREFIX=/lib64/qt6/qml
        )
        cmake_src_configure
}
