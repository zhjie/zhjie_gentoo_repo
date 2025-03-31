# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit cmake

DESCRIPTION="QTerm --- BBS client based on Qt"
HOMEPAGE="https://github.com/qterm/qterm"
SRC_URI="https://github.com/qterm/qterm/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="dev-libs/openssl
	dev-qt/qtbase:6
	dev-qt/qtmultimedia:6
	dev-qt/qttools:6
	dev-qt/qt5compat:6
"

DEPEND="
	dev-build/cmake
	${RDEPEND}
"

