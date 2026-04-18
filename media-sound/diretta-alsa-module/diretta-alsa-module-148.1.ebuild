# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 unpacker
MY_PV=$(ver_rs 1 '_')

DESCRIPTION="Linux Diretta ALSA Host kernel module"
HOMEPAGE="https://www.diretta.link/preview/"
ARM_MODULE="diretta-alsa-dkms-${MY_PV}-1-aarch64.pkg.tar.xz"
X86_MODULE="diretta-alsa-dkms-${MY_PV}-1-x86_64.pkg.tar.zst"

SRC_URI="
        arm64? ( https://www.audio-linux.com/repo_aarch64/${ARM_MODULE} )
        amd64? ( https://www.audio-linux.com/ftp/temp/diretta_v2/${X86_MODULE} )
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE=""

S="${WORKDIR}/${P}"

src_unpack() {
	unpacker_src_unpack
	mv usr/src/diretta-alsa-${MY_PV}/ "${S}" || die
}

src_compile() {
    local modlist=( "alsa_bridge=/kernel/sound/drivers/" )

    local modargs=(
        "KERNELDIR=${KV_OUT_DIR}"
    )

    linux-mod-r1_src_compile
}
