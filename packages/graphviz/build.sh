TERMUX_PKG_HOMEPAGE=https://www.graphviz.org/
TERMUX_PKG_DESCRIPTION="Rich set of graph drawing tools"
TERMUX_PKG_LICENSE="EPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="8.0.2"
TERMUX_PKG_SRCURL=https://gitlab.com/graphviz/graphviz/-/archive/$TERMUX_PKG_VERSION/graphviz-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=3d243a7db7b21643c795e4fdad03efaed71313723bf46932d99c17920160bb0d
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="fontconfig, freetype, gdk-pixbuf, glib, harfbuzz, libandroid-glob, libc++, libcairo, libexpat, libgd, libltdl, librsvg, libwebp, pango, zlib"
TERMUX_PKG_BREAKS="graphviz-dev"
TERMUX_PKG_REPLACES="graphviz-dev"
TERMUX_PKG_BUILD_DEPENDS="libtool"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-guile=no
--enable-java=no
--enable-lua=no
--enable-ocaml=no
--enable-perl=no
--enable-php=no
--enable-python=no
--enable-r=no
--enable-ruby=no
--enable-sharp=no
--enable-swig=no
--enable-tcl=no
--with-ann=no
--with-expatlibdir=$TERMUX_PREFIX/lib
--with-ltdl-include=$TERMUX_PREFIX/include
--with-ltdl-lib=$TERMUX_PREFIX/lib
--with-pangocairo=yes
--with-pic
--with-poppler=no
--with-x=no
"
TERMUX_PKG_FORCE_CMAKE=false
TERMUX_PKG_RM_AFTER_INSTALL="bin/*-config share/man/man1/*-config.1"

termux_step_pre_configure() {
	./autogen.sh NOCONFIG
	export HOSTCC="gcc"

	LDFLAGS+=" -lm -landroid-glob"
	LDFLAGS+=" $($CC -print-libgcc-file-name)"
	LDFLAGS+=" -Wl,-rpath=$TERMUX_PREFIX/lib/graphviz"
}

termux_step_create_debscripts() {
	echo "#!$TERMUX_PREFIX/bin/sh" > postinst
	echo "dot -c" >> postinst
	echo "exit 0" >> postinst
	chmod 0755 postinst
}
