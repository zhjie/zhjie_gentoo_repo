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
IUSE="zsh-completion bash-completion fish-completion"

BDEPEND=">=dev-lang/go-1.25.9"

src_compile() {
	ego build -o bin/glow
}

src_install() {
	dobin bin/glow

	if use bash-completion; then
		bin/glow completion bash >"${PN}" 2>&1 || die "generating bash completion failed"
		dobashcomp "${PN}"
	fi
	if use fish-completion; then
		bin/glow completion fish >"${PN}.fish" 2>&1 || die "generating fish completion failed"
		dofishcomp "${PN}.fish"
	fi
	if use zsh-completion; then
		bin/glow completion zsh >"_${PN}" 2>&1 || die "generating zsh completion failed"
		dozshcomp "_${PN}"
	fi

	einstalldocs
}
