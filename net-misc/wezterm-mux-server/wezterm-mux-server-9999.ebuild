# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 systemd

DESCRIPTION="WezTerm mux server and headless CLI proxy"
HOMEPAGE="https://wezfurlong.org/wezterm/"
EGIT_REPO_URI="https://github.com/wez/wezterm.git"
EGIT_CLONE_TYPE="shallow"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
RESTRICT="network-sandbox"

BDEPEND="|| (
    dev-lang/rust
    dev-lang/rust-bin
)"

src_compile() {
    cargo build --release --bin wezterm-mux-server || die
    cargo build --release --bin wezterm --no-default-features || die
}

src_install() {
    dobin target/release/wezterm-mux-server
    dobin target/release/wezterm

    systemd_douserunit "${FILESDIR}/wezterm-mux-server.service"
}

pkg_postinst() {
    elog "To enable the mux server for your user:"
    elog "  systemctl --user enable --now wezterm-mux-server.service"
    elog "Connect from WezTerm: wezterm connect SERVER"
}
