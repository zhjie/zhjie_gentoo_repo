# Copyright 1999-2025 Gentoo Authors
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

IUSE="doc"
RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( >=dev-python/docutils-0.21.1 )
"

src_configure() { :; }

do_rst2man_command() {
	rst2man \
		--syntax-highlight=none \
		"${1}" "${2}" || die "manpage generation failed"
}

src_compile() {
	sed -e "s:@VERSION@:${PV}:g;s:@PYTHON@:python:g" gobject/glib-genmarshal.in > gobject/glib-genmarshal || die
	sed -e "s:@VERSION@:${PV}:g;s:@PYTHON@:python:g" gobject/glib-mkenums.in > gobject/glib-mkenums || die
	sed -e "s:@GLIB_VERSION@:${PV}:g;s:@PYTHON@:python:g" glib/gtester-report.in > glib/gtester-report || die
	if use doc; then
	do_rst2man_command docs/reference/gobject/glib-genmarshal.rst docs/reference/gobject/glib-genmarshal.1
	do_rst2man_command docs/reference/gobject/glib-mkenums.rst docs/reference/gobject/glib-mkenums.1
	do_rst2man_command docs/reference/glib/gtester-report.rst docs/reference/glib/gtester-report.1
	fi
}

src_install() {
	python_fix_shebang gobject/glib-genmarshal
	python_fix_shebang gobject/glib-mkenums
	python_fix_shebang glib/gtester-report
	exeinto /usr/bin
	doexe gobject/glib-genmarshal
	doexe gobject/glib-mkenums
	doexe glib/gtester-report
	if use doc; then
	doman docs/reference/gobject/glib-genmarshal.1
	doman docs/reference/gobject/glib-mkenums.1
	doman docs/reference/glib/gtester-report.1
	fi
}
