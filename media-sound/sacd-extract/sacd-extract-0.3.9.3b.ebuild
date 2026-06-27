# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="SACD ripping software using a PS3"
HOMEPAGE="https://github.com/EuFlo/sacd-ripper"
SRC_URI="https://github.com/EuFlo/sacd-ripper/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"

DEPEND="dev-libs/libxml2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/sacd-ripper-${PV}/tools/sacd_extract"

src_install() {
	dobin "${WORKDIR}/sacd-ripper-${PV}/tools/sacd_extract_build/sacd_extract"
}
