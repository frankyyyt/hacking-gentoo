# Copyright 2012 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3
# $Header: $

# TODO:
#   bundled-deps: eigen:3 is too old
#                 bullet is modified
#   multiple python abi?

EAPI=5
PYTHON_COMPAT=( python3_3 )
#PATCHSET="1"

inherit multilib fdo-mime gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

case ${PV} in
	*_p*)
		SRC_URI="http://dev.gentoo.org/~lu_zero/${P}.tar.gz" ;;
	*)
		SRC_URI="http://download.blender.org/source/${P}.tar.gz" ;;
esac

if [[ -n ${PATCHSET} ]]; then
	SRC_URI+=" http://dev.gentoo.org/~flameeyes/${PN}/${P}-patches-${PATCHSET}.tar.xz"
fi

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"
IUSE="+boost +bullet collada colorio cycles +dds debug doc +elbeem ffmpeg fftw +game-engine jack jpeg2k ndof nls openal openmp +openexr player redcode sdl sndfile sse tiff"
REQUIRED_USE="player? ( game-engine ) redcode? ( jpeg2k ) cycles? ( boost ) nls? ( boost )"

RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/glog[gflags]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=media-libs/freetype-2.0
	media-libs/glew
	media-libs/libpng:0
	media-libs/libsamplerate
	sci-libs/colamd
	sci-libs/ldl
	sys-libs/zlib
	virtual/glu
	virtual/jpeg
	virtual/libintl
	virtual/opengl
	x11-libs/libXi
	x11-libs/libX11
	boost? ( >=dev-libs/boost-1.44[threads(+)] )
	collada? ( media-libs/opencollada )
	colorio? ( media-libs/opencolorio )
	cycles? (
		media-libs/openimageio
	)
	ffmpeg? (
		>=virtual/ffmpeg-0.6.90[x264,mp3,encode,theora,jpeg2k?]
	)
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	ndof? ( app-misc/spacenavd )
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openexr? ( media-libs/openexr )
	sdl? ( media-libs/libsdl[audio,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )"
DEPEND="${RDEPEND}
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx
	)
	nls? ( sys-devel/gettext )"

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.66-{unbundle,cmake,doxyfile}.patch
	epatch "${FILESDIR}"/dupligroup_depth.patch

	# remove some bundled deps
	rm -r \
		extern/libopenjpeg \
		extern/glew \
		extern/colamd \
		extern/binreloc \
		extern/libmv/third_party/{ldl,glog,gflags} \
		|| die

	# turn off binreloc (not cached)
	sed -i \
		-e 's#set(WITH_BINRELOC ON)#set(WITH_BINRELOC OFF)#' \
		CMakeLists.txt || die

	# we don't want static glew, but it's scattered across
	# thousand files
	sed -i \
		-e '/add_definitions(-DGLEW_STATIC)/d' \
		$(find . -type f -name "CMakeLists.txt") || die

	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; find extern/libmv/third_party -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags

	# WITH_PYTHON_SECURITY
	# WITH_PYTHON_SAFETY
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DWITH_INSTALL_PORTABLE=OFF
		$(cmake-utils_use_with boost BOOST)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with collada OPENCOLLADA)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with elbeem MOD_FLUID)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with fftw MOD_OCEANISM)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with sse RAYOPTIMIZATION)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with colorio OPENCOLORIO)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	cat - > "${T}"/${PN}.env <<EOF
BLENDER_SYSTEM_SCRIPTS="/usr/share/blender/${PV}/scripts"
BLENDER_SYSTEM_DATAFILES="/usr/share/blender/${PV}/datafiles"
BLENDER_SYSTEM_PLUGINS="/usr/$(get_libdir)/plugins"
EOF

	if use doc; then
		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_test() { :; }

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	newenvd "${T}"/${PN}.env 60${PN}

	if use doc; then
		docinto "API/python"
		dohtml -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/*

		docinto "API/blender"
		dohtml -r "${CMAKE_USE_DIR}"/doc/doxygen/html/*
	fi

	# linguas cleanup
	if ! use nls; then
		rm -r "${CMAKE_USE_DIR}"/release/datafiles/locale || die
	else
		if [[ -n "${LINGUAS+x}" ]] ; then
			for i in "${CMAKE_USE_DIR}"/release/datafiles/locale/* ; do
				mylang=${i##*/}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi

	# fucked up cmake will relink binary for no reason
	# on normal "install" rule
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	dohtml "${D}"/usr/share/doc/blender/readme.html
	rm -r "${D}"/usr/share/doc/blender || die

	python_fix_shebang "${D}"/usr/bin/blender-thumbnailer.py
	python_optimize "${D}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	ewarn "If you're updating from blender before 2.66, please make"
	ewarn "sure to log out and then back in before launching it, so"
	ewarn "that the new environment variables are picked up."
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}