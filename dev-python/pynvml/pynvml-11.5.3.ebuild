# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{10..13} )
inherit distutils-r1 pypi

DESCRIPTION="Python utilities for the NVIDIA Management Library"
HOMEPAGE="https://pypi.org/project/pynvml"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="dev-util/nvidia-cuda-toolkit
"
