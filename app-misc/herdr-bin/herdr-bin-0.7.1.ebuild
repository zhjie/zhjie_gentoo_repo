# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Terminal workspace manager for AI coding agents (binary release)"
HOMEPAGE="https://herdr.dev"
SRC_URI="
	amd64? ( https://github.com/ogulcancelik/herdr/releases/download/v${PV}/herdr-linux-x86_64 -> herdr-linux-x86_64-${PV} )
	arm64? ( https://github.com/ogulcancelik/herdr/releases/download/v${PV}/herdr-linux-aarch64 -> herdr-linux-aarch64-${PV} )
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE=""

S="${WORKDIR}"

src_install() {
	if use amd64; then
		newbin "${DISTDIR}/herdr-linux-x86_64-${PV}" herdr
	elif use arm64; then
		newbin "${DISTDIR}/herdr-linux-aarch64-${PV}" herdr
	fi
}
