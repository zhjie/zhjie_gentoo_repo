# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )
GNOME_ORG_MODULE="glib"

inherit gnome.org python-single-r1

DESCRIPTION="Build utilities for GLib using projects"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2.1+"
SLOT="0" # /usr/bin utilities that can't be parallel installed by their nature
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

KEYWORDS="amd64 arm64"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND=""

src_configure() { :; }

src_compile() {
	sed -e "s:@VERSION@:${PV}:g;s:@PYTHON@:python:g" gobject/glib-genmarshal.in > gobject/glib-genmarshal || die
	sed -e "s:@VERSION@:${PV}:g;s:@PYTHON@:python:g" gobject/glib-mkenums.in > gobject/glib-mkenums || die
	sed -e "s:@GLIB_VERSION@:${PV}:g;s:@PYTHON@:python:g" glib/gtester-report.in > glib/gtester-report || die
}

src_install() {
	python_fix_shebang gobject/glib-genmarshal
	python_fix_shebang gobject/glib-mkenums
	python_fix_shebang glib/gtester-report
	exeinto /usr/bin
	doexe gobject/glib-genmarshal
	doexe gobject/glib-mkenums
	doexe glib/gtester-report
}
