# Copyright 2026 Benny Powers
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_NPM_SCOPE="@earendil-works"
MY_WEBUI_NPM_NAME="pi-web-ui"
MY_WEBUI_P="${MY_WEBUI_NPM_NAME}-0.75.3"

DESCRIPTION="AI coding agent CLI with interactive TUI, tool calling, and session management"
HOMEPAGE="https://pi.dev https://github.com/earendil-works/pi"
SRC_URI="
	mirror://npm/${MY_NPM_SCOPE}/${PN}/-/${P}.tgz -> ${P}.tgz
	https://github.com/bennypowers/gentoo-overlay/releases/download/pi-coding-agent/${P}-deps.tar.xz
	webui? ( mirror://npm/${MY_NPM_SCOPE}/${MY_WEBUI_NPM_NAME}/-/${MY_WEBUI_P}.tgz -> ${MY_WEBUI_P}.tgz
		https://github.com/bennypowers/gentoo-overlay/releases/download/pi-coding-agent/${MY_WEBUI_P}-deps.tar.xz )
"
S="${WORKDIR}"

# NOTE: to generate the dependency tarball:
#       npm --cache ./npm-cache install $(portageq envvar DISTDIR)/${P}.tgz
#       tar -caf ${P}-deps.tar.xz npm-cache

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="webui"

RDEPEND=">=net-libs/nodejs-22"
BDEPEND=">=net-libs/nodejs-22[npm]"

# webui installs @earendil-works/pi-web-ui for web component chat interfaces

src_unpack() {
	cd "${T}" || die "Could not cd to temporary directory"
	unpack ${P}-deps.tar.xz
	if use webui; then
		unpack ${MY_WEBUI_P}-deps.tar.xz
	fi
}

src_install() {
	npm \
		--offline \
		--verbose \
		--progress false \
		--foreground-scripts \
		--global \
		--prefix "${ED}"/usr \
		--cache "${T}"/npm-cache \
		install "${DISTDIR}"/${P}.tgz || die "npm install failed"

	# Install optional web components when webui flag is enabled
	if use webui; then
		npm \
			--offline \
			--verbose \
			--progress false \
			--foreground-scripts \
			--global \
			--prefix "${ED}"/usr \
			--cache "${T}"/npm-cache \
			install "${DISTDIR}"/${MY_WEBUI_P}.tgz || die "npm install web-ui failed"
	fi

	cd "${ED}"/usr/$(get_libdir)/node_modules/${MY_NPM_SCOPE}/${PN} || die "cd failed"
	einstalldocs
}
