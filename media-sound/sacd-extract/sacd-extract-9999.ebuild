# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 eutils cmake

DESCRIPTION="SACD ripping software using a PS3"
HOMEPAGE="https://github.com/EuFlo/sacd-ripper.git"
EGIT_REPO_URI="https://github.com/EuFlo/sacd-ripper.git"
EGIT_CLONE_TYPE=shallow

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}-${PV}/tools/sacd_extract"

src_compile() {
    default
    cmake . -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-fcommon"
    make
}

src_install() {
    dobin sacd_extract
}
