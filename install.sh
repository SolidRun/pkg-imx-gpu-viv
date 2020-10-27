#!/bin/bash -e

source ${MESON_SOURCE_ROOT:=.}/functions.inc

#################################################################

# Vivante core graphics libraries
install_core_base() {
	# Vivante GPU HAL
	for bg in fb wayland x11; do
		install_gc_lib $bg/libGAL.so $bg/libGAL.so
	done
	# alternatives: libGAL.so -> $bg/libGAL.so
	install_headers HAL

	# Khronos shared headers
	install_headers KHR

	# EGL
	for bg in fb wayland x11; do
		install_gc_lib $bg/libEGL.so.1.5.0 $bg/libEGL.so.1
		link_gc_lib libEGL.so.1 $bg/libEGL.so
	done
	# alternatives: libEGL.so.1 -> $bg/libEGL.so.1
	link_gc_lib libEGL.so.1 libEGL.so.1.0.0 # compatibility symlink to the Mesa soname of libEGL
	link_gc_lib libEGL.so.1 libEGL.so
	install_headers EGL
	install_gc_pc egl_linuxfb egl_vivante_fb
	install_gc_pc egl_wayland egl_vivante_wl
	install_gc_pc egl_x11 egl_vivante_x11
	# TODO: alternatives

	# OpenGL
	for bg in fb wayland x11; do
		install_gc_lib $bg/libGL.so.1.2.0 $bg/libGL.so.1
		link_gc_lib libGL.so.1 $bg/libGL.so
	done
	link_gc_lib libGL.so.1 libGL.so.1.2
	link_gc_lib libGL.so.1 libGL.so
	install_gc_pc gl_x11 gl
	#install_headers GL
	install_header GL/glcorearb.h
	install_header GL/glext.h
	install_header GL/gl.h
	#install_header GL/glxext.h
	#install_header GL/glx.h

	# OpenGL-ES
	install_gc_lib libGLES_CL.so.1.1.0
	link_gc_lib libGLES_CL.so.1.1.0 libGLES_CL.so.1
	link_gc_lib libGLES_CL.so.1 libGLES_CL.so
	install_gc_lib libGLES_CM.so.1.1.0
	link_gc_lib libGLES_CM.so.1.1.0 libGLES_CM.so.1
	link_gc_lib libGLES_CM.so.1 libGLES_CM.so
	install_headers GLES

	# OpenGL-ES 1.1
	install_gc_lib libGLESv1_CL.so.1.1.0
	link_gc_lib libGLESv1_CL.so.1.1.0 libGLESv1_CL.so.1
	link_gc_lib libGLESv1_CL.so.1 libGLESv1_CL.so
	install_gc_lib libGLESv1_CM.so.1.1.0
	link_gc_lib libGLESv1_CM.so.1.1.0 libGLESv1_CM.so.1
	link_gc_lib libGLESv1_CM.so.1 libGLESv1_CM.so
	install_gc_pc glesv1_cm glesv1_cm_vivante_fb
	install_gc_pc glesv1_cm glesv1_cm_vivante_wl
	install_gc_pc glesv1_cm_x11 glesv1_cm_vivante_x11

	# OpenGL-ES 2.0
	for bg in fb wayland x11; do
		install_gc_lib $bg/libGLESv2.so.2.0.0 $bg/libGLESv2.so.2
		link_gc_lib libGLESv2.so.2 $bg/libGLESv2.so
	done
	# alternatives: libGLESv2.so.2 -> $bg/libGLESv2.so.2
	link_gc_lib libGLESv2.so.2 libGLESv2.so.2.0.0 # Mesa compat
	link_gc_lib libGLESv2.so.2 libGLESv2.so
	install_headers GLES2
	install_gc_pc glesv2 glesv2_vivante_fb
	install_gc_pc glesv2 glesv2_vivante_wl
	install_gc_pc glesv2_x11 glesv2_vivante_x11
	# TODO: alternatives

	# OpenGL-ES 3.0
	# part of libGLESv2.so
	install_headers GLES3
	# TODO: alternatives

	# GL Shader Compiler
	install_gc_lib libGLSLC.so

	# OpenVG
	test "x$_arch" = "xarm" && install_gc_lib libOpenVG.2d.so
	install_gc_lib libOpenVG.3d.so.1.1.0 libOpenVG.so.1
	link_gc_lib libOpenVG.so.1 libOpenVG.so
	install_headers VG
	install_gc_pc vg vg_vivante_fb
	install_gc_pc vg vg_vivante_wl
	install_gc_pc vg_x11 vg_vivante_x11
	# TODO: alternative for VG?

	# OpenVX (only aarch64)
	if [ "x$_arch" = "xaarch64" ]; then
		install_gc_lib libOpenVX.so.1.2.0 libOpenVX.so.1
		link_gc_lib libOpenVX.so.1 libOpenVX.so
		install_gc_lib libOpenVXU.so
		install_gc_lib libOvx12VXCBinary-evis.so
		install_gc_lib libOvx12VXCBinary-evis2.so
		install_headers VX

		# neural networks (using ovx)
		install_gc_lib libArchModelSw.so
		install_gc_lib libNNArchPerf.so
		install_gc_lib libNNGPUBinary-evis.so
		install_gc_lib libNNGPUBinary-evis2.so
		install_gc_lib libNNGPUBinary-lite.so
		install_gc_lib libNNGPUBinary-ulite.so
		install_gc_lib libNNVXCBinary-evis.so
		install_gc_lib libNNVXCBinary-evis2.so
	fi

	if [ "x$skip_cl" = "xno" ]; then
	# OpenCL (only GC2000)
		install_gc_lib libOpenCL.so.1.2.0 libOpenCL.so.1
		link_gc_lib libOpenCL.so.1 libOpenCL.so
		install_gc_lib libCLC.so
		install_headers CL

		install_gc_lib libVivanteOpenCL.so

		install_conf Vivante.icd OpenCL/vendors/Vivante.icd
	fi

	# Vulkan (only aarch64)
	if [ "x$_arch" = "xaarch64" ]; then
		install_gc_lib libSPIRV_viv.so
		for bg in fb wayland x11; do
			install_gc_lib $bg/libvulkan.so.1.1.6 $bg/libvulkan.so.1
			link_gc_lib libvulkan.so.1 $bg/libvulkan.so
		done
		link_gc_lib libvulkan.so.1 libvulkan.so
		install_headers vulkan
	fi

	# VDK
	for bg in fb wayland x11; do
		install_gc_lib $bg/libVDK.so.1.2.0 $bg/libVDK.so.1
		link_gc_lib libVDK.so.1 $bg/libVDK.so
	done
	# alternatives: libVDK.so.1 -> $bg/libVDK.so.1
	link_gc_lib libVDK.so.1 libVDK.so
	install_header gc_vdk.h
	install_header gc_vdk_types.h
	install_header vdk.h

	# VSC
	install_gc_lib libVSC.so

	return
}

install_core_fb() {
	return
}

install_core_x11() {
	# DRI
	install_dri_driver vivante_dri.so
	return
}

install_core_wl() {
	install_custom_gc_pc wayland-egl

	return
}

install_core_alternatives() {
	update-alternatives --remove-all vivante-gal
	prio=0
	for bg in fb wayland x11; do
		((prio=prio+10))
		update-alternatives \
			--install /usr/lib/galcore/libGAL.so vivante-gal /usr/lib/galcore/$bg/libGAL.so $prio \
			--slave /usr/lib/galcore/libEGL.so.1 vivante-egl /usr/lib/galcore/$bg/libEGL.so.1 \
			--slave /usr/lib/galcore/libGLESv2.so.2 vivante-gles2 /usr/lib/galcore/$bg/libGLESv2.so.2 \
			--slave /usr/lib/galcore/libVDK.so vivante-vdk /usr/lib/galcore/$bg/libVDK.so
	done
}

install_libgbm() {
	install_lib libgbm.so vivante/libgbm.so
	install_gc_lib libgbm_viv.so
	install_header gbm.h
	install_pc gbm
}

install_demos() {
	mkdir -p "${_destdir}/opt/"

	# OpenCL demos
	if [ "x$skip_cl" = "xno" ]; then
		mkdir -p "${_destdir}/opt/viv_samples"
		cp -rv "${SOURCESDIR}/opt/viv_samples/cl11" "${_destdir}/opt/viv_samples/"
	fi

	# Graphics demos
	mkdir -p "${_destdir}/opt/viv_samples"
	cp -rv "${SOURCESDIR}/opt/viv_samples/es20" "${_destdir}/opt/viv_samples/"
	cp -rv "${SOURCESDIR}/opt/viv_samples/tiger" "${_destdir}/opt/viv_samples/"
	cp -rv "${SOURCESDIR}/opt/viv_samples/vdk" "${_destdir}/opt/viv_samples/"

	return
}

install_tools() {
	_SOURCESDIR="${SOURCESDIR}"
	SOURCESDIR="${SOURCESDIR}/gmem-info"
	install_bin gmem_info
	return
}

#################################################################

# handle arguments and set default paths
usage() {
	echo Userspace installer for Vivante graphics driver
	echo Usage: $0 [OPTIONS]
	echo
	echo "	--arch               cpu architecture"
	echo
	echo "	--destdir            installation prefix"
	echo "	--libdir             directory for libraries"
	echo "	--includedir         directory for header files"
	echo "	--dridir             directory for DRI drivers"
	echo "	--sysconfdir         directory for system-wide configuration files"
	echo "	--bindir  	     directory for binaries"
	echo "  --skip-alternatives  dont run update-alternatives"
	echo
	echo "  --skip-cl            dont install OpenCL parts"
	echo
}

s=0
OPTIONS=`getopt -n "$0" -o "" -l "destdir:,libdir:,includedir:,dridir:,bindir:,sysconfdir:,arch:,skip-alternatives,skip-cl" -- "$@"` || s=$?
if [ $s -ne 0 ]; then
	usage
	exit 1
fi

_destdir=/
_libdir=/usr/lib
_bindir=/usr/bin
_includedir=/usr/include
_dridir=/usr/lib/dri
_sysconfdir=/etc
_arch=arm
skip_alternatives=no
skip_cl=no
eval set -- "$OPTIONS"
while true; do
	case $1 in
		--libdir)
			_libdir=$2
			shift 2
			;;
		--bindir)
			_bindir=$2
			shift 2
			;;
		--includedir)
			_includedir=$2
			shift 2
			;;
		--dridir)
			_dridir=$2
			shift 2
			;;
		--destdir)
			_destdir=$2
			shift 2
			;;
		--sysconfdir)
			_sysconfdir=$2
			shift 2
			;;
		--arch)
			_arch=$2
			shift 2
			;;
		--skip-alternatives)
			skip_alternatives=yes
			shift 1
			;;
		--skip-cl)
			skip_cl=yes
			shift 1
			;;
		--)
			shift
			break
			;;
	esac
done

if [ ! -z "$DESTDIR" ]; then
	_destdir=$DESTDIR
fi

# check arguments validity

if [ ! -d "${_destdir}" ]; then
	echo "Warning: ${_destdir} does not exist yet, going to create it."
fi

case $_arch in
	arm)
		fslpkgname=imx-gpu-viv-6.4.3.p0.0-aarch32.bin
		fslpkgchksum=163167d49e1667bab3a8a37ea33b7624
		;;
	aarch64)
		fslpkgname=imx-gpu-viv-6.4.3.p0.0-aarch64.bin
		fslpkgchksum=db4c88a19d0c1f7ec2788531822f9144
		;;
	*)
		echo "invalid value \"${_arch}\"for option --arch"
		exit 1
		;;
esac

#################################################################

echo "Going to install Freescale Vivante userspace 6.4.3.p0.0"

# download the vivante binary package
pushd $MESON_SOURCE_ROOT
MIRRORS="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/ http://download.ossystems.com.br/bsp/freescale/source/"
fetch $fslpkgname $fslpkgchksum
popd

# unpack the archive at the current location
unpack $MESON_SOURCE_ROOT/$fslpkgname

basedir="$MESON_SOURCE_ROOT"
vivantebindir="$MESON_BUILD_ROOT/`basename $fslpkgname .bin`"

# perform installation

SOURCESDIR="${vivantebindir}/gpu-core"
install_core_base
install_core_fb
install_core_wl
install_core_x11
install_libgbm

# patch headers
find ${_destdir}/${_includedir} -type f -exec sed -i "s;defined(LINUX);defined(__linux__);g" {} \;

if [ "$skip_alternatives" = "no" ]; then
	install_core_alternatives
fi

SOURCESDIR="${vivantebindir}/gpu-tools"
install_tools

SOURCESDIR="${vivantebindir}/gpu-demos"
install_demos

# MESON
# finally install libgbm wrapper
# (needed because of custom install script)
install -v -m755 -D $MESON_BUILD_ROOT/wrappers/libgbm.so.1.0.0 $MESON_INSTALL_DESTDIR_PREFIX/lib/libgbm.so.1.0.0
ln -sv libgbm.so.1.0.0 $MESON_INSTALL_DESTDIR_PREFIX/lib/libgbm.so.1
ln -sv libgbm.so.1 $MESON_INSTALL_DESTDIR_PREFIX/lib/libgbm.so
