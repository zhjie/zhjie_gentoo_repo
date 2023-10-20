# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit readme.gentoo-r1 systemd unpacker pax-utils

_APPNAME="plexmediaserver"
_USERNAME="plex"
_SHORTNAME="${_USERNAME}"
_FULL_VERSION="${PV}-${COMMIT}"

URI="https://www.plex.tv/media-server-downloads"

DESCRIPTION="Free media library that is intended for use with a plex client"
HOMEPAGE="https://www.plex.tv/"
SRC_URI="
https://downloads.plex.tv/plex-media-server-new/1.32.6.7557-1cf77d501/debian/plexmediaserver_1.32.6.7557-1cf77d501_amd64.deb
"
S="${WORKDIR}"

LICENSE="Plex"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror bindist"

DEPEND="
	acct-group/plex
	acct-user/plex"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/plexmediaserver.service.amd64.patch" )

QA_DESKTOP_FILE="usr/share/applications/plexmediamanager.desktop"
QA_PREBUILT="*"
QA_MULTILIB_PATHS=(
	"usr/lib/plexmediaserver/lib/.*"
	"usr/lib/plexmediaserver/Resources/Python/lib/python2.7/.*"
	"usr/lib/plexmediaserver/Resources/Python/lib/python2.7/lib-dynload/_hashlib.so"
)

BINS_TO_PAX_MARK=(
	"${ED}/usr/lib/plexmediaserver/Plex Script Host"
	"${ED}/usr/lib/plexmediaserver/Plex Media Scanner"
)

src_install() {
	rm -r "usr/share" || die

	# Remove tuner and useless plugins
	rm -r usr/lib/plexmediaserver/CrashUploader
	rm -r usr/lib/plexmediaserver/Plex\ Tuner\ Service
	rm -r usr/lib/plexmediaserver/Plex\ DLNA\ Server
	rm -r usr/lib/plexmediaserver/Plex\ Transcoder
        rm -r usr/lib/plexmediaserver/Resources/Fonts
	rm -r usr/lib/plexmediaserver/Resources/Tuner
	rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/Musicbrainz.bundle
	rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/PlexMusic.bundle
	rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/LyricFind.bundle
	rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/OpenSubtitles.bundle
        rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/LastFM.bundle
	rm -r usr/lib/plexmediaserver/Resources/Plug-ins-*/PlexThemeMusic.bundle

	# Copy main files over to image and preserve permissions so it is portable
	cp -rp usr/ "${ED}" || die

	# Make sure the logging directory is created
	keepdir /var/log/pms
	fowners plex:plex /var/log/pms

	# Create default library folder with correct permissions
	keepdir /var/lib/plexmediaserver
	fowners plex:plex /var/lib/plexmediaserver

	# Install the OpenRC init/conf files
	newinitd "${FILESDIR}/${PN}.init.d" ${PN}
	newconfd "${FILESDIR}/${PN}.conf.d" ${PN}

	# Install systemd service file
	systemd_newunit "${ED}"/usr/lib/plexmediaserver/lib/plexmediaserver.service "${PN}.service"

	# Add pax markings to some binaries so that they work on hardened setup
	for f in "${BINS_TO_PAX_MARK[@]}"; do
		pax-mark m "${f}"
	done

	# Adds the precompiled plex libraries to the revdep-rebuild's mask list
	# so it doesn't try to rebuild libraries that can't be rebuilt.
	insinto /etc/revdep-rebuild
	doins "${FILESDIR}"/80plexmediaserver

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
