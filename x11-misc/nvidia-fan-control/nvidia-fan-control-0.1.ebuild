# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

MY_PN=${PN/}

DESCRIPTION="NVIDIA GPU Fan Control"
HOMEPAGE="https://github.com/RoversX/nvidia_fan_control_linux"
SRC_URI="https://github.com/RoversX/nvidia_fan_control_linux/raw/refs/heads/main/nvidia_fan_control.py"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"


RDEPEND="dev-python/pynvml"

DEPEND="${RDEPEND}"

src_unpack() {
	mkdir -p "${WORKDIR}/${P}"
	cp "${DISTDIR}/nvidia_fan_control.py" "${WORKDIR}/${P}"
}

src_install() {
	eapply "${FILESDIR}/flush.patch"
	dobin nvidia_fan_control.py
	newinitd "${FILESDIR}/nvidia-fan-control.init.d" "nvidia-fan-control"
}
