# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="SACD ripping software using a PS3"
HOMEPAGE="https://github.com/EuFlo/sacd-ripper.git"
SRC_URI="https://github.com/sacd-ripper/sacd-ripper/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE=""

DEPEND="dev-libs/libxml2"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}-${PV}/tools/sacd_extract"

src_compile() {
    default
#     cmake . -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-fcommon"
#    make
}

src_install() {
    default
#    dobin sacd_extract
}
