# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Hexdump utility from vim"
HOMEPAGE="https://www.vim.org/"
SRC_URI="
	https://raw.githubusercontent.com/vim/vim/v${PV}/src/xxd/xxd.c -> ${P}.c
	https://raw.githubusercontent.com/vim/vim/v${PV}/src/xxd/Makefile -> ${P}.mk"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"

RDEPEND="!app-editors/vim-core"

S="${WORKDIR}"

src_unpack() {
	cp "${DISTDIR}/${P}.c" xxd.c || die "cp failed"
	cp "${DISTDIR}/${P}.mk" Makefile || die "cp failed"
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	dobin xxd
}
