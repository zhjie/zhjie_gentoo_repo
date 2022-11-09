# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

MY_PV="${PV}"

DESCRIPTION=".NET is a free, cross-platform, open-source developer platform"
HOMEPAGE="https://dotnet.microsoft.com/"
LICENSE="MIT"

SRC_URI="amd64? (
https://download.visualstudio.microsoft.com/download/pr/367108bb-8782-4f0b-839d-c98191b7729a/94185f91ef33890816a5846a374b74b7/dotnet-runtime-6.0.11-linux-x64.tar.gz
)"

SLOT="6.0"
KEYWORDS="~amd64"
IUSE="+dotnet-symlink"
REQUIRED_USE="elibc_glibc"
QA_PREBUILT="*"
RESTRICT+=" splitdebug"
RDEPEND="
	app-crypt/mit-krb5:0/0
	dev-util/lttng-ust:0
	sys-libs/zlib:0/1
	dotnet-symlink? ( !dev-dotnet/dotnet-runtime[dotnet-symlink(+)] )
        !dev-dotnet/dotnet-sdk-bin
"

S=${WORKDIR}

src_install() {
	local dest="opt/${PN}-${SLOT}"
	dodir "${dest%/*}"

	{ mv "${S}" "${ED}/${dest}" && mkdir "${S}" && fperms 0755 "/${dest}"; } || die
	dosym "../../${dest}/dotnet" "/usr/bin/dotnet-bin-${SLOT}"

	if use dotnet-symlink; then
		dosym "../../${dest}/dotnet" "/usr/bin/dotnet"
		dosym "../../${dest}/dotnet" "/usr/bin/dotnet-${SLOT}"

		# set an env-variable for 3rd party tools
		echo "DOTNET_ROOT=/${dest}" > "${T}/90${PN}-${SLOT}" || die
		doenvd "${T}/90${PN}-${SLOT}"
	fi
}
