# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT="96084fff27fc91142460e5cc32b7ececdb72d048"
DESCRIPTION="SACD ripping software using a PS3"
HOMEPAGE="https://github.com/EuFlo/sacd-ripper.git"
SRC_URI="https://github.com/EuFlo/sacd-ripper/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

DEPEND="dev-libs/libxml2"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/sacd-ripper-${COMMIT}/tools/sacd_extract"

src_install() {
    dobin ${WORKDIR}/sacd-ripper-${COMMIT}/tools/sacd_extract_build/sacd_extract
}
