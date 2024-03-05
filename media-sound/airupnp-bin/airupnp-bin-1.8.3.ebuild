# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="AirConnect: Send audio to UPnP players using AirPlay"
HOMEPAGE="https://github.com/philippe44/AirConnect"
SRC_URI="https://github.com/philippe44/AirConnect/raw/4f391a9b62f2591af495ed668f31d67515ea32b9/AirConnect-1.8.3.zip -> ${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

DEPEND="systemd? ( sys-apps/systemd )"
QA_PREBUILT="/usr/bin/airupnp"

src_unpack() {
	mkdir "${WORKDIR}/${P}"
	cd "${WORKDIR}/${P}"
	unpack ${A}
}

src_install() {
	newbin "$WORKDIR/${P}"/airupnp-linux-x86_64 airupnp || die

        if use systemd ; then
		systemd_dounit "${FILESDIR}"/airupnp.service
        else
		newinitd "${FILESDIR}"/airupnp.init.d airupnp
	fi
}
