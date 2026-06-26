# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1

DESCRIPTION="Fish-like autosuggestions for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-autosuggestions"
SRC_URI="https://github.com/zsh-users/zsh-autosuggestions/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/all/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=app-shells/zsh-4.3.11"
BDEPEND=""

S="${WORKDIR}/${P}"

src_install() {
	insinto "/usr/share/zsh/site-functions/"
	doins "${PN}.zsh"
}
