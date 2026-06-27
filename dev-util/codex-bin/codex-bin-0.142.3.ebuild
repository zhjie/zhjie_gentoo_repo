# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-codex-bin-update.yaml
EAPI=8
DESCRIPTION="Codex CLI is a coding agent from OpenAI that runs locally on your computer."
HOMEPAGE="https://github.com/openai/codex"
SRC_URI="
	amd64? (  https://github.com/openai/codex/releases/download/rust-v${PV}/codex-x86_64-unknown-linux-musl.tar.gz -> ${P}-codex-x86_64-unknown-linux-musl.tar.gz  )
	arm64? (  https://github.com/openai/codex/releases/download/rust-v${PV}/codex-aarch64-unknown-linux-musl.tar.gz -> ${P}-codex-aarch64-unknown-linux-musl.tar.gz  )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64"

REQUIRED_USE=""
RDEPEND=""

QA_PREBUILT="opt/bin/codex"

S="${WORKDIR}"

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe "codex-x86_64-unknown-linux-musl" "codex" || die "Failed to install Binary"
	fi
	if use arm64; then
		newexe "ccodex-aarch64-unknown-linux-musl" "codex" || die "Failed to install Binary"
	fi
}
