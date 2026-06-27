# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 unpacker
MY_PV_BASE="$(ver_cut 1)_$(ver_cut 2)"
MY_MINOR="$(ver_cut 3)"

DESCRIPTION="Linux Diretta Direct kernel module"
HOMEPAGE="https://www.diretta.link/preview/"

SRC_URI="
		arm64? ( https://www.audio-linux.com/repo_aarch64/diretta-direct-dkms-${MY_PV_BASE}-${MY_MINOR}-aarch64.pkg.tar.xz )
		amd64? ( https://www.audio-linux.com/ftp/temp/diretta_v2/diretta-direct-dkms-${MY_PV_BASE}-${MY_MINOR}-x86_64.pkg.tar.zst )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE=""

S="${WORKDIR}/${P}"

src_unpack() {
	unpacker_src_unpack
	mv usr/src/diretta-direct-${MY_PV_BASE}/ "${S}" || die
}

src_compile() {
	local modlist=("diretta_direct=/kernel/sound/drivers/")

	local modargs=(
		"KERNELDIR=${KV_OUT_DIR}"
	)

	linux-mod-r1_src_compile
}
