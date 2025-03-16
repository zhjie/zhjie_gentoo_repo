# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Hexdump utility from vim"
HOMEPAGE="https://www.vim.org/"
SRC_URI="https://github.com/vim/vim/archive/refs/tags/v${PV}.tar.gz -> vim-${PV}.tar.gz"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm64 arm"

RESTRICT="mirror"

RDEPEND="!app-editors/vim-core"

S="${WORKDIR}"

src_unpack() {
	unpack vim-${PV}.tar.gz
	cp "${S}/vim-${PV}/src/xxd/xxd.c"    xxd.c    || die "cp failed"
        cp "${S}/vim-${PV}/src/xxd/Makefile" Makefile || die "cp failed"
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	dobin xxd
}
