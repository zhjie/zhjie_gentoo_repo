# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Apple Lossless Audio Codec library"
HOMEPAGE="https://github.com/mikebrady/alac"
SRC_URI="https://github.com/mikebrady/alac/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="amd64 arm64"

src_configure() {
	autoreconf -i -f
	econf
}
