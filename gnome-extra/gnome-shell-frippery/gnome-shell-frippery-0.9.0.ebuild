# Copyright 2013 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3+
# $Header: $

EAPI="5"

DESCRIPTION="Unofficial extension pack providing GNOME 2-like features for GNOME 3"
HOMEPAGE="http://intgat.tigress.co.uk/rmy/extensions/index.html"
SRC_URI="http://intgat.tigress.co.uk/rmy/extensions/${P}.tgz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	app-eselect/eselect-gnome-shell-extensions
	>=dev-libs/gjs-1.29
	dev-libs/gobject-introspection
	gnome-base/gnome-menus:3[introspection]
	>=gnome-base/gnome-shell-3.14
	media-libs/clutter:1.0[introspection]
	x11-libs/pango[introspection]
"
DEPEND=""

S="${WORKDIR}/.local/share/gnome-shell"

src_install() {
	insinto /usr/share/gnome-shell/extensions
	doins -r extensions/*@*
	dodoc gnome-shell-frippery/{CHANGELOG,README}
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
