#!/bin/bash -e

source functions.inc

#################################################################

# Vivante core graphics libraries
install_core_base() {
	# Vivante GPU HAL
	for bg in fb dfb wl x11; do
		install_gc_lib libGAL-$bg.so $bg/libGAL.so
	done
	# alternatives: libGAL.so -> $bg/libGAL.so

	for bg in fb dfb wl; do
		install_gc_lib libGAL_egl.$bg.so $bg/libGAL_egl.so
	done
	install_gc_lib libGAL_egl.dri.so x11/libGAL_egl.so
	# alternatives: libGAL_egl.so -> $bg/libGAL_egl.so
	install_headers HAL

	# Khronos shared headers
	install_headers KHR

	# EGL
	link_gc_lib libEGL.so.1.0 libEGL.so.1.0.0 # compatibility symlink to the Mesa soname of libEGL
	for bg in fb dfb wl x11; do
		install_gc_lib libEGL-$bg.so $bg/libEGL.so
	done
	# alternatives: libEGL.so.1.0 -> $bg/libEGL.so
	install_custom_gc_pc egl
	link_gc_lib libEGL.so.1.0 libEGL.so.1
	link_gc_lib libEGL.so.1 libEGL.so
	install_headers EGL

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
	install_custom_gc_pc glesv1_cm

	# OpenGL-ES 2.0
	for bg in fb dfb wl x11; do
		install_gc_lib libGLESv2-$bg.so $bg/libGLESv2.so
	done
	link_gc_lib libGLESv2.so.2 libGLESv2.so.2.0.0 # Mesa compat
	# alternatives: libGLESv2.so.2 -> $bg/libGLESv2.so
	link_gc_lib libGLESv2.so.2 libGLESv2.so
	install_headers GLES2
	install_custom_gc_pc glesv2

	# OpenGL-ES 3.0
	# part of libGLESv2.so
	install_headers GLES3

	# GL Shader Compiler
	install_gc_lib libGLSLC.so

	# OpenVG
	install_gc_lib libOpenVG.2d.so
	install_gc_lib libOpenVG.3d.so
	link_gc_lib libOpenVG.3d.so libOpenVG.so
	install_headers VG
	install_custom_gc_pc vg
	# TODO: alternative for VG?

	if [ "x$skip_cl" = "xno" ]; then
	# OpenCL (only GC2000)
		install_gc_lib libOpenCL.so
		install_gc_lib libCLC.so
		install_headers CL

		install_gc_lib libVivanteOpenCL.so
	fi

	# VDK
	install_gc_lib libVDK.so
	install_header gc_vdk.h
	install_header gc_vdk_hal.h
	install_header gc_vdk_types.h
	install_header vdk.h

	# miscellaneous
	install_conf Vivante.icd
	install_gc_lib libVSC.so
	for bg in fb dfb wl x11; do
		install_gc_lib libVIVANTE-$bg.so $bg/libVIVANTE.so
	done
	# alternatives: libVIVANTE.so -> $bg/libVIVANTE.so

	return
}

install_core_fb() {
	return
}

install_core_dfb() {
	install_lib directfb-1.7-4/gfxdrivers/libdirectfb_gal.so
	install_conf directfbrc
	return
}

install_core_x11() {
	# X11 OpenGL GLX
	install_gc_lib libGL.so.1.2
	link_gc_lib libGL.so.1.2 libGL.so
	install_custom_gc_pc gl

	# create fake libGL.so.1 (mesa libgl soname)
	gcc -shared -Wl,-soname=libGL.so.1 -L${_destdir}/${_libdir}/galcore -lGL -o ${_destdir}/${_libdir}/galcore/libGL.so.1

	# DRI
	install_dri_driver vivante_dri.so
	return
}

install_core_wl() {
	install_custom_gc_pc wayland-egl

	# Wayland libs
	install_gc_lib libgc_wayland_protocol.so.0.0.0
	link_gc_lib libgc_wayland_protocol.so.0.0.0 libgc_wayland_protocol.so.0
	link_gc_lib libgc_wayland_protocol.so.0 libgc_wayland_protocol.so
	install_gc_lib libgc_wayland_protocol.a
	install_pc gc_wayland_protocol

	install_gc_lib libwayland-viv.so.0.0.0
	link_gc_lib libwayland-viv.so.0.0.0 libwayland-viv.so.0
	link_gc_lib libwayland-viv.so.0 libwayland-viv.so
	install_gc_lib libwayland-viv.a
	install_pc wayland-viv
	install_headers wayland-viv

	# TODO: update paths in installed .pc-files
	return
}

install_core_alternatives() {
	update-alternatives --remove-all vivante-gal
	prio=0
	for bg in fb dfb wl x11; do
		((prio=prio+10))
		update-alternatives \
			--install /usr/lib/galcore/libGAL.so vivante-gal /usr/lib/galcore/$bg/libGAL.so $prio \
			--slave /usr/lib/galcore/libEGL.so.1.0 vivante-egl /usr/lib/galcore/$bg/libEGL.so \
			--slave /usr/lib/galcore/libGLESv2.so.2 vivante-gles2 /usr/lib/galcore/$bg/libGLESv2.so \
			--slave /usr/lib/galcore/libVIVANTE.so vivante-vivante /usr/lib/galcore/$bg/libVIVANTE.so
	done
}

install_g2d() {
	install_lib libg2d-viv.so libg2d.so.0.8
	link_lib libg2d.so.0.8 libg2d.so
	install_header g2d.h
	return
}

install_demos() {
	mkdir -p "${_destdir}/opt/"
	cp -rv "${SOURCESDIR}/opt/fsl-samples" "${_destdir}/opt/"

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
	install_bin gmem_info
	return
}

install_apitrace_nonx11() {
	install_bin apitrace
	install_bin eglretrace
	install_gc_lib apitrace/wrappers/egltrace.so
	mkdir -p "${_destdir}/usr/lib/apitrace"
	cp -rv "${SOURCESDIR}/usr/lib/apitrace/scripts" "${_destdir}/${_libdir}/apitrace/"
	mkdir -p "${_destdir}/usr/share/doc/"
	cp -rv "${SOURCESDIR}/usr/share/doc/apitrace" "${_destdir}/usr/share/doc/"
	return
}

install_apitrace_x11() {
	install_apitrace_nonx11
	install_bin glretrace
	install_gc_lib apitrace/wrappers/glxtrace.so
	return
}

#################################################################

# handle arguments and set default paths
usage() {
	echo Userspace installer for Vivante graphics driver
	echo Usage: $0 [OPTIONS]
	echo
	echo "	--fhw                floating-point hardware (hard|soft)"
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
  soft) ;;
  hard) ;;
  *)    echo "invalid value \"${_fhw}\"for option --fhw"
	exit 1
	;;
esac

#################################################################

echo "Going to install Freescale Vivante userspace 5.0.11 p4.4"

# download the vivante binary package
MIRRORS="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/ http://download.ossystems.com.br/bsp/freescale/source/"
if [ "x$_fhw" = "xhard" ]; then
	fslpkgname=imx-gpu-viv-5.0.11.p4.5-hfp.bin
	fslpkgchksum=8314408acb6b3bc58fcbbb8a0f48b54b
else
	fslpkgname=imx-gpu-viv-5.0.11.p4.5-sfp.bin
	fslpkgchksum=479dce20e0e2f9f7d0a4e4ff70d4a4b2
fi
fetch $fslpkgname $fslpkgchksum

# unpack the archive at the current location
unpack $fslpkgname

basedir="$PWD"
vivantebindir="$basedir/`basename $fslpkgname .bin`"

# perform installation

SOURCESDIR="${vivantebindir}/gpu-core"
install_core_base
install_core_fb
install_core_dfb
install_core_wl
install_core_x11

# patch headers
find ${_destdir}/${_includedir} -type f -exec sed -i "s;defined(LINUX);defined(linux);g" {} \;

if [ "$skip_alternatives" = "no" ]; then
	install_core_alternatives
fi

SOURCESDIR="${vivantebindir}/gpu-demos"
install_demos

SOURCESDIR="${vivantebindir}/g2d"
install_g2d

SOURCESDIR="${vivantebindir}/apitrace/x11"
#install_apitrace_x11
SOURCESDIR="${vivantebindir}/apitrace/non-x11"
#install_apitrace_nonx11
