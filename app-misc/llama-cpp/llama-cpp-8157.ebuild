# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit cmake python-single-r1 cuda

DESCRIPTION="LLM inference in C/C++ optimized for Zen 5 and Ada Lovelace"
HOMEPAGE="https://github.com/ggerganov/llama.cpp"

if [[ ${PV} == 9999 ]]; then
    inherit git-r3
    EGIT_REPO_URI="https://github.com/ggerganov/llama.cpp.git"
else
    MY_PV="b${PV}"
    SRC_URI="https://github.com/ggerganov/llama.cpp/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
    S="${WORKDIR}/${PN}-${MY_PV}"
    KEYWORDS="~amd64"
fi
S="${WORKDIR}/llama.cpp-${MY_PV}"
LICENSE="MIT"
SLOT="0"

IUSE="+cuda +server lto"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
    ${PYTHON_DEPS}
    <sys-devel/gcc-15
    cuda? ( dev-util/nvidia-cuda-toolkit )
"
DEPEND="${RDEPEND}"

src_prepare() {
    cmake_src_prepare
    if use cuda; then
        cuda_src_prepare
    fi
}

src_configure() {
    # Force CUDA architecture for RTX 4090 (Compute Capability 8.9)
    export CUDA_ARCH="89"

    local mycmakeargs=(
	-DCMAKE_CUDA_ARCHITECTURES=89
	-DGGML_NATIVE=ON
	-DGGML_LTO=$(usex lto)

	-DGGML_CUDA=$(usex cuda)
        -DGGML_CUDA_F16=$(usex cuda)
        -DGGML_CUDA_GRAPHS=$(usex cuda)
	-DGGML_CUDA_FLASH_ATTN=$(usex cuda)

        -DLLAMA_BUILD_SERVER=$(usex server)
        -DBUILD_SHARED_LIBS=ON
    )

    cmake_src_configure
}

src_install() {
    cmake_src_install
    local script="${S}/convert_hf_to_gguf.py"
    if [[ -f "${script}" ]]; then
        python_fix_shebang "${script}"
        newbin "${script}" llama-convert-hf-to-gguf
    fi

    insinto /usr/share/${PN}
    doins requirements/*.txt
}
