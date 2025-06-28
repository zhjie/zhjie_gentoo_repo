# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2 vala

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgee"

LICENSE="LGPL-2.1+"
SLOT="0.8/2"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc x86 ~x86-linux"
IUSE="+introspection vala"

# FIXME: add doc support, requires valadoc
RDEPEND="
	>=dev-libs/glib-2.36:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.6:= )
"
DEPEND="
	${RDEPEND}
	vala? ( $(vala_depend) )
"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	if use vala; then
		vala_setup
	fi
	gnome2_src_prepare
}

src_configure() {
	# Commented out VALAC="$(type -P false)" for c99 patches
	# We can drop all the Vala wiring and use the shipped files once
	# a new release is made.
	gnome2_src_configure \
		$(use_enable vala) \
		$(use_enable introspection)
		
}
