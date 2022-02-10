# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Unite is an extension that makes GNOME Shell look like Ubuntu Unity Shell."
HOMEPAGE="https://extensions.gnome.org/extension/1287/unite"
EGIT_REPO_URI="https://github.com/hardpixel/unite-shell.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="${COMMON_DEPEND}
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-3.22
"
DEPEND="${COMMON_DEPEND}"

src_install() {
	dodir "/usr/share/gnome-shell/extensions/"
	cp -R "${S}/unite@hardpixel.eu" "${D}/usr/share/gnome-shell/extensions/" || die "Install failed!"
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
