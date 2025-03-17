# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=0ubuntu1

inherit meson xdg

DESCRIPTION="Yaru theme from the Ubuntu Community"
HOMEPAGE="https://discourse.ubuntu.com/c/desktop/theme-refresh"
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+files/${PN}_${PV}${UVER}-${UREV}.tar.xz"

LICENSE="CC-BY-SA-4.0 GPL-3 LGPL-2.1 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="cinnamon gnome-shell gtk mate unity xfwm"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	x11-themes/gtk-engines-adwaita
	x11-themes/gtk-engines-murrine

	gtk? ( sys-apps/xdg-desktop-portal-gtk )
"
BDEPEND="
	dev-libs/glib:2
	dev-libs/libxml2:2
	dev-lang/sassc
"

S="${WORKDIR}/${PN}-${UREV}"

ubuntu-versionator_src_prepare() {
        debug-print-function ${FUNCNAME} "$@"

        local \
               	color_bold=$(tput bold) \
                color_norm=$(tput sgr0) \
                x

        # Apply Ubuntu diff file if present #
        local diff_file="${PN}_${PV}${UVER}-${UREV}.diff"
        [[ -f ${WORKDIR}/${diff_file} ]] && diff_file="${WORKDIR}/${diff_file}"
        if [[ -f ${diff_file} ]]; then
                echo "${color_bold}>>> Processing Ubuntu diff file${color_norm} ..."
                eapply "${diff_file}"
                echo "${color_bold}>>> Done.${color_norm}"
        fi

        # Apply Ubuntu patchset if one is present #
        local upatch_dir="debian/patches"
        local -a upatches
        [[ -f ${WORKDIR}/${upatch_dir}/series ]] && upatch_dir="${WORKDIR}/debian/patches"
        if [[ -f ${upatch_dir}/series ]]; then
                for x in $(grep -v \# "${upatch_dir}/series"); do
                        upatches+=( "${upatch_dir}/${x}" )
                done
        fi
        if [[ -n ${upatches[@]} ]]; then
                echo "${color_bold}>>> Processing Ubuntu patchset${color_norm} ..."
                eapply "${upatches[@]}"
                echo "${color_bold}>>> Done.${color_norm}"
        fi

        if declare -F vala_setup 1>/dev/null; then
                vala_setup
                export VALA_API_GEN="${VAPIGEN}"
        fi

        if declare -F cmake_src_prepare 1>/dev/null; then
                cmake_src_prepare
        elif declare -F distutils-r1_src_prepare 1>/dev/null; then
                distutils-r1_src_prepare
        elif declare -F gnome2_src_prepare 1>/dev/null; then
                gnome2_src_prepare
        else
                default
        fi

        [[ ${UBUNTU_EAUTORECONF} == 'yes' ]] && eautoreconf
}

src_prepare() {
	## Fix mate-terminal background color ##
	sed -i \
		-e '/vte-terminal {/{n;s/$_mate_terminal_bg_color/#300A24/}' \
		gtk/src/default/gtk-3.0/apps/_mate-terminal.scss || die

	## Add nemo nautilus-like theme ##
	cat "${FILESDIR}"/nemo.css >> \
		gtk/src/default/gtk-3.0/apps/_nemo.scss || die

	## Add widget fixes ##
	cat "${FILESDIR}"/gtk-widgets.css >> \
		gtk/src/default/gtk-3.0/_tweaks.scss || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dgnome-shell-user-themes-support=$(usex gnome-shell enabled disabled)
		-Dgtk=true
		-Dgtksourceview=true
		-Dicons=true
		-Dmetacity=true
		-Dsessions=false
		-Dsounds=true
		$(meson_use cinnamon )
		$(meson_use cinnamon cinnamon-dark )
		$(meson_use cinnamon cinnamon-shell )
		$(meson_use gnome-shell )
		$(meson_use gnome-shell gnome-shell-gresource )
		$(meson_use mate )
		$(meson_use mate mate-dark )
		$(meson_use unity ubuntu-unity )
		$(meson_use xfwm xfwm4 )
	)
	meson_src_configure
}
