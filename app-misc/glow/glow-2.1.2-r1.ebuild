# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion

DESCRIPTION="Render markdown on the CLI, with pizzazz!"
HOMEPAGE="https://github.com/charmbracelet/glow"
SRC_URI="https://github.com/charmbracelet/glow/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/ingenarel/guru-depfiles/releases/download/${P}-deps.tar.xz/${P}-go-mod-deps.tar.xz -> ${P}-deps.tar.xz
"

LICENSE="MIT"
LICENSE+=" Apache-2.0 BSD MIT "
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25.9"

src_compile() {
	ego build -o bin/glow
}

src_install() {
	dobin bin/glow
}
