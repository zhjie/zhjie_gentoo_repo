# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="nqptp is a companion application to Shairport Sync and provides timing information for AirPlay 2 operation."
HOMEPAGE="https://github.com/mikebrady/nqptp"
SRC_URI="https://github.com/mikebrady/nqptp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86 arm arm64"
IUSE="systemd"

DEPEND="dev-libs/libconfig
	sys-apps/coreutils[caps]
"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
}

src_configure() {
	autoreconf -i -f
	econf
}

src_install() {
	dobin nqptp
	#	emake DESTDIR="${D}" install
	if use systemd; then
		systemd_dounit "${FILESDIR}"/nqptp.service
	else
		newinitd "${FILESDIR}"/nqptp.init.d nqptp
	fi
}
