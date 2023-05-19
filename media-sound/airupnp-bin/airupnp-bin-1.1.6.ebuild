# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="AirConnect: Send audio to UPnP players using AirPlay"
HOMEPAGE="https://github.com/philippe44/AirConnect"
SRC_URI="https://raw.githubusercontent.com/philippe44/AirConnect/1101ab07848ae7a8b8a19fddf9bf1fddce49779c/bin/airupnp-linux-x86_64-static -> airupnp"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

DEPEND="systemd? ( sys-apps/systemd )"

src_unpack() {
        mkdir "${WORKDIR}/${PF}"
        cp -Hv "${DISTDIR}"/airupnp "${WORKDIR}/${PF}"/airupnp || die
}

src_install() {
        newbin "${WORKDIR}/${PF}"/airupnp airupnp    || die
        keepdir /var/lib/airupnp/                    || die

        if use systemd ; then
		systemd_dounit "${FILESDIR}"/airupnp.service
        else
		newinitd "${FILESDIR}"/airupnp.init.d airupnp
	fi
}
