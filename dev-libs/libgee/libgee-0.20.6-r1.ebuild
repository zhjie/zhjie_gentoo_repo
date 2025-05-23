# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2 vala

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgee"

LICENSE="LGPL-2.1+"
SLOT="0.8/2"
KEYWORDS="amd64 arm64"
IUSE="introspection vala"

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

PATCHES=(
	"${FILESDIR}"/libgee-0.20.6-c99.patch
	"${FILESDIR}"/libgee-0.20.6-c99-2.patch
	"${FILESDIR}"/hashmap.patch
)

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
		$(use_enable introspection) \
		$(use_enable vala)
}
