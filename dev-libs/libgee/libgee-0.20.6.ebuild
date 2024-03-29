# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome2

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgee"

LICENSE="LGPL-2.1+"
SLOT="0.8/2"
KEYWORDS="~alpha amd64 arm arm64 ~ia64 ~loong ppc ppc64 ~riscv sparc x86 ~x86-linux"
IUSE="+introspection clang"

# FIXME: add doc support, requires valadoc
RDEPEND="
	>=dev-libs/glib-2.36:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
        if use clang; then
		CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
        fi

	gnome2_src_configure \
		$(use_enable introspection) \
		VALAC="$(type -P false)"
}
