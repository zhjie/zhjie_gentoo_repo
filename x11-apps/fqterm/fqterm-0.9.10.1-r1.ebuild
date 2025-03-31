# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit cmake git-r3

DESCRIPTION="a modern terminal emulator for Linux with qt5"
EGIT_REPO_URI="https://github.com/mytbk/fqterm.git"
EGIT_COMMIT="3f95c09e7a24a0f1c16db0d6cfaf3d9754e2e085"
HOMEPAGE="https://github.com/mytbk/fqterm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	dev-libs/openssl
        dev-qt/qtscript:5
        dev-qt/linguist-tools:5
        dev-qt/qtmultimedia:5
"

DEPEND="
	dev-build/cmake
	${RDEPEND}
"

src_install() {
        cmake_src_install
        dolib.so "${WORKDIR}/${P}_build"/src/common/libfqterm_common.so
        dolib.so "${WORKDIR}/${P}_build"/src/ui/imageviewer/libfqterm_imageviewer.so
        dolib.so "${WORKDIR}/${P}_build"/src/fqterm/libfqterm_main.so
        dolib.so "${WORKDIR}/${P}_build"/src/protocol/libfqterm_protocol.so
        dolib.so "${WORKDIR}/${P}_build"/src/terminal/libfqterm_terminal.so
        dolib.so "${WORKDIR}/${P}_build"/src/ui/libfqterm_ui.so
        dolib.so "${WORKDIR}/${P}_build"/src/utilities/libfqterm_utilities.so
}
