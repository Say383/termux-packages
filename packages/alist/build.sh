TERMUX_PKG_HOMEPAGE=https://alist.nn.ci
TERMUX_PKG_DESCRIPTION="A file list program that supports multiple storage"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="2096779623 <admin@utermux.dev>"
TERMUX_PKG_VERSION=(3.15.1) # alist version
TERMUX_PKG_VERSION+=(3.15.1) # alist-web version
TERMUX_PKG_SRCURL=(https://github.com/alist-org/alist/archive/v${TERMUX_PKG_VERSION}.tar.gz
		   https://github.com/alist-org/alist-web/releases/download/${TERMUX_PKG_VERSION[1]}/dist.tar.gz)
TERMUX_PKG_SHA256=(563accf652d7b7d422e0a99027db14d52daee451dad32729e00f9b4074aaa4d1
		   b7a111edd85a11b14393e38558b637edfa5b3c69a95b15cbbd8749ce26320f9f)
TERMUX_PKG_BUILD_IN_SRC=true
# termux_pkg_upgrade_version couldn't check multiple versions now.
TERMUX_PKG_AUTO_UPDATE=false

termux_step_post_get_source() {
	rm -rf public/dist
	mv -f dist public
}

termux_step_make() {
	termux_setup_golang

	local ldflags
	local _builtAt=$(date +'%F %T %z')
	local _goVersion=$(go version | sed 's/go version //')
	local _gitAuthor="Andy Hsu <i@nn.ci>"
	local _gitCommit=$(git ls-remote https://github.com/alist-org/alist refs/tags/v$TERMUX_PKG_VERSION | head -c 7)
	export CGO_ENABLED=1

	ldflags="\
	-w -s \
	-X 'github.com/alist-org/alist/v3/internal/conf.BuiltAt=$_builtAt' \
	-X 'github.com/alist-org/alist/v3/internal/conf.GoVersion=$_goVersion' \
	-X 'github.com/alist-org/alist/v3/internal/conf.GitAuthor=$_gitAuthor' \
	-X 'github.com/alist-org/alist/v3/internal/conf.GitCommit=$_gitCommit' \
	-X 'github.com/alist-org/alist/v3/internal/conf.Version=$TERMUX_PKG_VERSION' \
	-X 'github.com/alist-org/alist/v3/internal/conf.WebVersion=${TERMUX_PKG_VERSION[1]}' \
	"
	go build -o "${TERMUX_PKG_NAME}" -ldflags="$ldflags" -tags=jsoniter
}

termux_step_make_install() {
	install -Dm700 ./"${TERMUX_PKG_NAME}" "${TERMUX_PREFIX}"/bin

	install -Dm644 /dev/null "${TERMUX_PREFIX}/share/bash-completion/completions/alist.bash"
	install -Dm644 /dev/null "${TERMUX_PREFIX}/share/zsh/site-functions/_alist"
	install -Dm644 /dev/null "${TERMUX_PREFIX}/share/fish/vendor_completions.d/alist.fish"
}

termux_step_create_debscripts() {
	cat <<- EOF > ./postinst
		#!${TERMUX_PREFIX}/bin/sh
		alist completion bash > ${TERMUX_PREFIX}/share/bash-completion/completions/alist.bash
		alist completion zsh > ${TERMUX_PREFIX}/share/zsh/site-functions/_alist
		alist completion fish > ${TERMUX_PREFIX}/share/fish/vendor_completions.d/alist.fish
	EOF
}
