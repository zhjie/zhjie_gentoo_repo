# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal toolchain-funcs

DESCRIPTION="Hardware monitoring library (libsensors only)"
HOMEPAGE="https://hwmon.wiki.kernel.org/ https://github.com/lm-sensors/lm-sensors"

SRC_URI="https://github.com/hramrach/lm-sensors/archive/V$(ver_rs 1- -).tar.gz -> lm-sensors-${PV}.tar.gz"
S="${WORKDIR}/lm-sensors-$(ver_rs 1- -)"

LICENSE="LGPL-2.1"

# SUBSLOT based on SONAME of libsensors.so
SLOT="0/5.0.0"

KEYWORDS="~alpha amd64 arm arm64 ~loong ~mips ppc ppc64 ~riscv ~sparc x86"
IUSE="static-libs"

RDEPEND="!sys-apps/lm-sensors"
DEPEND="
	app-alternatives/yacc
	app-alternatives/lex"

src_prepare() {
	default

	# Respect LDFLAGS
	sed -i -e 's/\$(LIBDIR)$/\$(LIBDIR) \$(LDFLAGS)/g' Makefile || \
		die "Failed to sed in LDFLAGS"

	if ! use static-libs; then
		sed -i -e '/^BUILD_STATIC_LIB/d' Makefile || \
			die "Failed to disable static building"
	fi

	multilib_copy_sources
}

multilib_src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)"
}

multilib_src_install() {
	emake \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)" \
		DESTDIR="${ED}" \
		PREFIX="/usr" \
		MANDIR="/usr/share/man" \
		ETCDIR="/etc" \
		LIBDIR="/usr/$(get_libdir)" \
		install

	# Remove everything except the library and pkg-config files
	rm -rf \
		"${ED}/usr/bin" \
		"${ED}/usr/sbin" \
		"${ED}/etc" \
		"${ED}/usr/share" \
		|| die
}

