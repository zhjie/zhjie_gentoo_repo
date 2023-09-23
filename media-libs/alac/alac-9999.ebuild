# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools git-r3

DESCRIPTION="Apple Lossless Audio Codec library"
HOMEPAGE="https://github.com/mikebrady/alac"
EGIT_REPO_URI="https://github.com/mikebrady/alac.git"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm64 ~arm"

src_configure() {
	autoreconf -i -f
	econf
}
