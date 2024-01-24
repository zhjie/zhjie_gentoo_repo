# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="AirConnect: Send audio to UPnP players using AirPlay"
HOMEPAGE="https://github.com/philippe44/AirConnect"
SRC_URI="https://github.com/philippe44/AirConnect/raw/f907d6414751530f36e78f20662dbd7317f6d494/AirConnect-1.8.1.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

DEPEND="systemd? ( sys-apps/systemd )"

src_unpack() {
	ls "${WORKDIR}/"
	mkdir "${WORKDIR}/${PF}"
	cd "${WORKDIR}/${PF}"
	unpack ${A}
	ls "${WORKDIR}/"
}

src_install() {
        newbin "$WORKDIR/${PF}"/airupnp-linux-x86_64 airupnp || die

        if use systemd ; then
		systemd_dounit "${FILESDIR}"/airupnp.service
        else
		newinitd "${FILESDIR}"/airupnp.init.d airupnp
	fi
}
