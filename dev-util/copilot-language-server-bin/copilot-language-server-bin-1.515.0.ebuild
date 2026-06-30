# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Language Server Protocol server for GitHub Copilot (binary release from NPM)"
HOMEPAGE="https://github.com/github/copilot-language-server-release"
SRC_URI="
	amd64? ( https://registry.npmjs.org/@github/copilot-language-server-linux-x64/-/copilot-language-server-linux-x64-${PV}.tgz -> copilot-language-server-linux-x64-${PV}.tgz )
	arm64? ( https://registry.npmjs.org/@github/copilot-language-server-linux-arm64/-/copilot-language-server-linux-arm64-${PV}.tgz -> copilot-language-server-linux-arm64-${PV}.tgz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

IUSE=""

S="${WORKDIR}/package"

src_unpack() {
	default
}

src_install() {
	dobin copilot-language-server
}
