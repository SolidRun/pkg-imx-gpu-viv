#!/bin/bash -e

source functions.inc

#################################################################

# Vivante core graphics libraries
install_core_base() {
	# Vivante GPU HAL
	for bg in fb wl x11; do
		install_gc_lib libGAL-$bg.so $bg/libGAL.so
	done
	# alternatives: libGAL.so -> $bg/libGAL.so
	install_headers HAL

	# Khronos shared headers
	install_headers KHR

	# EGL
	for bg in fb wl x11; do
		install_gc_lib libEGL-$bg.so $bg/libEGL.so.1
		link_gc_lib libEGL.so.1 $bg/libEGL.so
	done
	# alternatives: libEGL.so.1 -> $bg/libEGL.so.1
	link_gc_lib libEGL.so.1.0 libEGL.so.1.0.0 # compatibility symlink to the Mesa soname of libEGL
	link_gc_lib libEGL.so.1 libEGL.so.1.0
	link_gc_lib libEGL.so.1 libEGL.so
	install_headers EGL
	install_gc_pc egl_linuxfb egl_vivante_fb
	install_gc_pc egl_wayland egl_vivante_wl
	install_gc_pc egl_x11 egl_vivante_x11
	# TODO: alternatives

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
	install_gc_pc glesv1_cm

	# OpenGL-ES 2.0
	for bg in fb wl x11; do
		install_gc_lib libGLESv2-$bg.so $bg/libGLESv2.so.2
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
	install_gc_pc glesv1_cm glesv1_cm_vivante_fb
	install_gc_pc glesv1_cm glesv1_cm_vivante_wl
	install_gc_pc glesv1_cm_x11 glesv1_cm_vivante_x11
	# TODO: alternatives

	# GL Shader Compiler
	install_gc_lib libGLSLC.so

	# OpenVG
	install_gc_lib libOpenVG.2d.so
	install_gc_lib libOpenVG.3d.so
	link_gc_lib libOpenVG.3d.so libOpenVG.so
	install_headers VG
	install_gc_pc vg
	# TODO: alternative for VG?

	if [ "x$skip_cl" = "xno" ]; then
	# OpenCL (only GC2000)
		install_gc_lib libOpenCL.so
		install_gc_lib libCLC.so
		install_gc_lib libLLVM_viv.so
		install_headers CL

		install_gc_lib libVivanteOpenCL.so

		install_conf Vivante.icd OpenCL/vendors/Vivante.icd
	fi

	# VDK
	for bg in fb wl x11; do
		install_gc_lib libVDK-$bg.so $bg/libVDK.so
	done
	# alternatives: libVDK.so -> $bg/libVDK.so
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
	# X11 OpenGL GLX
	install_gc_lib libGL.so.1.2
	link_gc_lib libGL.so.1.2 libGL.so
	install_gc_pc gl_x11 gl

	# GL headers
	install_headers GL

	# create fake libGL.so.1 (mesa libgl soname)
	${CROSS_COMPILE}gcc -shared -Wl,-soname=libGL.so.1 -L${_destdir}/${_libdir}/galcore -lGL -o ${_destdir}/${_libdir}/galcore/libGL.so.1

	# DRI
	install_dri_driver vivante_dri.so
	return
}

install_core_wl() {
	install_custom_gc_pc wayland-egl

	# Wayland libs
	install_gc_lib libgc_wayland_protocol.so.0.0.0 libgc_wayland_protocol.so.0
	link_gc_lib libgc_wayland_protocol.so.0 libgc_wayland_protocol.so.0.0.0
	link_gc_lib libgc_wayland_protocol.so.0 libgc_wayland_protocol.so
	install_gc_lib libgc_wayland_protocol.a
	install_gc_pc gc_wayland_protocol

	install_gc_lib libwayland-viv.so.0.0.0 libwayland-viv.so.0
	link_gc_lib libwayland-viv.so.0 libwayland-viv.so.0.0.0
	link_gc_lib libwayland-viv.so.0 libwayland-viv.so
	install_gc_lib libwayland-viv.a
	install_gc_pc wayland-viv
	install_headers wayland-viv

	# TODO: update paths in installed .pc-files
	return
}

install_core_alternatives() {
	update-alternatives --remove-all vivante-gal
	prio=0
	for bg in fb wl x11; do
		((prio=prio+10))
		update-alternatives \
			--install /usr/lib/galcore/libGAL.so vivante-gal /usr/lib/galcore/$bg/libGAL.so $prio \
			--slave /usr/lib/galcore/libEGL.so.1 vivante-egl /usr/lib/galcore/$bg/libEGL.so.1 \
			--slave /usr/lib/galcore/libGLESv2.so.2 vivante-gles2 /usr/lib/galcore/$bg/libGLESv2.so.2 \
			--slave /usr/lib/galcore/libVDK.so vivante-vdk /usr/lib/galcore/$bg/libVDK.so
	done
}

install_libgbm() {
	install_lib libgbm.so
	install_lib gbm_viv.so
	install_header gbm.h
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
	echo "	--fhw                floating-point hardware (hard)"
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
OPTIONS=`getopt -n "$0" -o "" -l "destdir:,libdir:,includedir:,dridir:,bindir:,sysconfdir:,fhw:,skip-alternatives,skip-cl" -- "$@"` || s=$?
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
_fhw=hard
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
		--fhw)
			_fhw=$2
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

# check arguments validity

if [ ! -d "${_destdir}" ]; then
	echo "Warning: ${_destdir} does not exist yet, going to create it."
fi

case $_fhw in
  hard) ;;
  *)    echo "invalid value \"${_fhw}\"for option --fhw"
	exit 1
	;;
esac

#################################################################

echo "Going to install Freescale Vivante userspace 5.0.11 p4.4"

# download the vivante binary package
MIRRORS="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/ http://download.ossystems.com.br/bsp/freescale/source/"
	fslpkgname=imx-gpu-viv-6.2.2.p0-aarch32.bin
	fslpkgchksum=7d43f73b8bc0c1c442587f819218a1d5
fetch $fslpkgname $fslpkgchksum

# unpack the archive at the current location
unpack $fslpkgname

basedir="$PWD"
vivantebindir="$basedir/`basename $fslpkgname .bin`"

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
