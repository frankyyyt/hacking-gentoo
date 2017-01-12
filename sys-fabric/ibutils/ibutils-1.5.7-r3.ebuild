# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

OFED_VER="3.12"
OFED_RC="1"
OFED_RC_VER="1"
OFED_SUFFIX="0.1.g05a9d1a"
OFED_SNAPSHOT="1"

inherit autotools openib

DESCRIPTION="OpenIB userspace tools"
KEYWORDS="~amd64 ~x86 ~amd64-linux"
IUSE=""

DEPEND="sys-fabric/libibverbs:${SLOT}
		>=dev-lang/tk-8.4"
RDEPEND="${DEPEND}
		!sys-fabric/openib-userspace"

block_other_ofed_versions

src_prepare() {
	epatch "${FILESDIR}/ibutils-tk-8.6.patch"
	
	# Rerun autotools
    einfo "Regenerating autotools files..."
	cd "${S}"
	./autogen.sh
}
