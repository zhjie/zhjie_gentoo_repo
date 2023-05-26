# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic
SRC_URI="https://github.com/Thomas-Tsai/partclone/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
S="${WORKDIR}/${PN}-${PV}"

DESCRIPTION="Partition cloning tool"
HOMEPAGE="https://partclone.org"

LICENSE="GPL-2"
SLOT="0"
IUSE="
apfs btrfs +e2fs exfat f2fs +fat fuse hfs minix ncurses nilfs2 ntfs xfs
"

RDEPEND="
	dev-libs/openssl:=
	e2fs? ( sys-fs/e2fsprogs )
	btrfs? ( sys-apps/util-linux )
	fuse? ( sys-fs/fuse:0 )
	ncurses? ( sys-libs/ncurses:0 )
	nilfs2? ( sys-fs/nilfs-utils )
	ntfs? ( sys-fs/ntfs3g:= )
	xfs? ( sys-apps/util-linux )
"
DEPEND="
	${RDEPEND}
"
DOCS=( AUTHORS ChangeLog HACKING NEWS README.md TODO )

src_prepare() {
	default
	eautoreconf
	append-cflags -fno-strict-aliasing
	sed \
		-e "s:\<gcc\>:$(tc-getBUILD_CC) ${CFLAGS}:" \
		-e "s:\<objcopy\>:$(tc-getBUILD_OBJCOPY):" \
		-i fail-mbr/compile-mbr.sh
}

src_configure() {
	local myconf=(
		$(use_enable e2fs extfs)
		$(use_enable apfs)
		$(use_enable btrfs)
		$(use_enable exfat)
		$(use_enable f2fs)
		$(use_enable fat)
		$(use_enable fuse)
		$(use_enable hfs hfsp)
		$(use_enable minix)
		$(use_enable ncurses ncursesw)
		$(use_enable nilfs2)
		$(use_enable ntfs)
		$(use_enable xfs)
	)
	econf "${myconf[@]}"
}
