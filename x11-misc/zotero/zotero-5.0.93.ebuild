# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit xdg-utils gnome2-utils

PN="Zotero"

DESCRIPTION="Zotero is a free, easy-to-use tool to help you collect, organize, cite, and share research."
HOMEPAGE="https://www.zotero.org/"
SRC_URI="https://download.zotero.org/client/release/${PV}/${PN}-${PV}_linux-x86_64.tar.bz2"

S="${WORKDIR}/${PN}_linux-x86_64"

IUSE=""
LICENSE="GPL-3"
KEYWORDS="~amd64"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"

ZOTERO_INSTALL_DIR="/opt/zotero"

src_prepare() {
	sed -i -e 's#^Exec=.*#Exec=/opt/bin/zotero#' zotero.desktop
	sed -i -e 's#Icon=zotero.*#Icon=zotero#' zotero.desktop
	rm extensions/* -rf
	eapply_user
}
src_install() {
	# install zotero files to /opt/zotero
	dodir ${ZOTERO_INSTALL_DIR}
	cp -a ${S}/. ${D}${ZOTERO_INSTALL_DIR} || die "Install failed!"

	dosym ${ZOTERO_INSTALL_DIR}/zotero /opt/bin/zotero

	newicon -s 256 chrome/icons/default/default256.png zotero.png

	insinto /usr/share/applications
	doins zotero.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
