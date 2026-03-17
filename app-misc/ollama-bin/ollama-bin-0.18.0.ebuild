# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker systemd

DESCRIPTION="Local runner for LLMs"
HOMEPAGE="https://ollama.com/
	https://github.com/ollama/ollama/"
SRC_URI="
	https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64.tar.zst
			-> ollama-${PV}-linux-amd64.tar.zst
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="amd64"
IUSE="systemd cuda mlx vulkan"

QA_PREBUILT="*"

src_install() {
	if ! use cuda; then
		rm -rf ./lib/ollama/cuda_v12
	fi

		rm -rf ./lib/ollama/cuda_v13

	if ! use mlx; then
		rm -rf ./lib/ollama/mlx_cuda_v13
	fi

	if ! use vulkan; then
		rm -rf ./lib/ollama/vulkan
	fi

        exeinto /opt/ollama/bin
        doexe "${WORKDIR}/bin/ollama" || die "Failed to install binary"

        insinto /opt/ollama/lib/
        doins -r "${WORKDIR}/lib/ollama/" || die "Failed to install libraries"
        dosym /opt/ollama/bin/ollama /usr/bin/ollama

        if use systemd; then
                systemd_dounit "${FILESDIR}"/ollama.service
        else
                doinitd "${FILESDIR}"/ollama
        fi
}

