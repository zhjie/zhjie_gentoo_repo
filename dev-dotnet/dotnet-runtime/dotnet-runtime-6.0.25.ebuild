# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

MY_PV="${PV}"

DESCRIPTION=".NET is a free, cross-platform, open-source developer platform"
HOMEPAGE="https://dotnet.microsoft.com/"
LICENSE="MIT"

SRC_URI="
https://download.visualstudio.microsoft.com/download/pr/0e8de3f9-7fda-46b7-9337-a3709c8e385d/bc29c53eb79fda25abb0fb9be60c6a22/dotnet-runtime-6.0.25-linux-x64.tar.gz
"

SLOT="6.0"
KEYWORDS="amd64"
IUSE="+dotnet-symlink trace"
REQUIRED_USE="elibc_glibc"
QA_PREBUILT="*"
RESTRICT+=" splitdebug"
RDEPEND="
	trace? ( dev-util/lttng-ust )
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

	if ! use trace; then
		rm -rfv "../../${dest}/shared/Microsoft.NETCore.App/6.0.25/libcoreclrtraceptprovider.so" || die
	fi

	if use dotnet-symlink; then
		dosym "../../${dest}/dotnet" "/usr/bin/dotnet"
		dosym "../../${dest}/dotnet" "/usr/bin/dotnet-${SLOT}"

		# set an env-variable for 3rd party tools
		echo "DOTNET_ROOT=/${dest}" > "${T}/90${PN}-${SLOT}" || die
		doenvd "${T}/90${PN}-${SLOT}"
	fi
}
