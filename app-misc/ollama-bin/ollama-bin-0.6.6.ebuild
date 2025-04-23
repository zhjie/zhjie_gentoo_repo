# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="Get up and running with large language models."
HOMEPAGE="https://ollama.com"
SRC_URI="
	amd64? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64.tgz  -> $P.tgz  )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="systemd"
S="${WORKDIR}"
RESTRICT="strip"

RDEPEND="
"

#src_unpack() {
#	tar -xzf "${DISTDIR}/${P}.tgz" -C "${WORKDIR}" || die "Failed to extract binary"
#}

src_install() {
	exeinto /opt/ollama/bin
	doexe "${WORKDIR}/bin/ollama" || die "Failed to install binary"

	rm -rfv "${WORKDIR}"/lib/ollama/cuda_v11
	insinto /opt/ollama/lib/
	doins -r "${WORKDIR}/lib/ollama/" || die "Failed to install libraries"
	dosym /opt/ollama/bin/ollama /usr/bin/ollama

	if use systemd; then
		systemd_dounit "${FILESDIR}"/ollama.service
	else
		doinitd "${FILESDIR}"/ollama
	fi
}
