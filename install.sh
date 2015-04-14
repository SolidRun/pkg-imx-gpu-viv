#!/bin/bash -e

source functions.inc

#################################################################

# Vivante core graphics libraries
install_core_base() {
	# Vivante GPU HAL
	install_headers HAL

	# Khronos shared headers
	install_headers KHR

	# EGL
	link_lib libEGL.so.1.0 libEGL.so.1.0.0 # compatibility symlink to the Mesa soname of libEGL
	# libEGL.so.1.0 backend dependent
	link_lib libEGL.so.1.0 libEGL.so.1
	link_lib libEGL.so.1 libEGL.so
	install_headers EGL

	# OpenGL-ES
	install_lib libGLES_CL.so.1.1.0
	link_lib libGLES_CL.so.1.1.0 libGLES_CL.so.1
	link_lib libGLES_CL.so.1 libGLES_CL.so
	install_lib libGLES_CM.so.1.1.0
	link_lib libGLES_CM.so.1.1.0 libGLES_CM.so.1
	link_lib libGLES_CM.so.1 libGLES_CM.so
	install_headers GLES

	# OpenGL-ES 1.1
	install_lib libGLESv1_CL.so.1.1.0
	link_lib libGLESv1_CL.so.1.1.0 libGLESv1_CL.so.1
	link_lib libGLESv1_CL.so.1 libGLESv1_CL.so
	install_lib libGLESv1_CM.so.1.1.0
	link_lib libGLESv1_CM.so.1.1.0 libGLESv1_CM.so.1
	link_lib libGLESv1_CM.so.1 libGLESv1_CM.so
	install_custom_pc glesv1_cm

	# OpenGL-ES 2.0
	# libGLESv2.so.2.0.0 backend-dependent
	link_lib libGLESv2.so.2.0.0 libGLESv2.so.2
	link_lib libGLESv2.so.2 libGLESv2.so
	install_headers GLES2
	install_custom_pc glesv2

	# OpenGL-ES 3.0
	install_headers GLES3

	# GL Shader Compiler
	install_lib libGLSLC.so

	# OpenVG
	install_lib libOpenVG.2d.so
	install_lib libOpenVG.3d.so
	link_lib libOpenVG.3d.so libOpenVG.so
	install_headers VG
	install_custom_pc vg

	if [ "x$skip_cl" = "xno" ]; then
	# OpenCL (only GC2000)
		install_lib libOpenCL.so
		install_lib libCLC.so
		install_headers CL

		install_lib libVivanteOpenCL.so
	fi

	# VDK
	install_lib libVDK.so
	install_header gc_vdk.h
	install_header gc_vdk_hal.h
	install_header gc_vdk_types.h
	install_header vdk.h

	# miscellaneous
	install_conf Vivante.icd
	install_lib libVSC.so

	return
}

install_core_fb() {
	install_lib libGAL-${_backend}.so libGAL.so
	install_lib libGAL_egl.${_backend}.so libGAL_egl.so
	install_lib libEGL-${_backend}.so libEGL.so.1.0
	install_custom_pc egl_fb egl
	install_lib libGLESv2-${_backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${_backend}.so libVIVANTE.so
	return
}

install_core_dfb() {
	install_lib libGAL-${_backend}.so libGAL.so
	install_lib libGAL_egl.${_backend}.so libGAL_egl.so
	install_lib libEGL-${_backend}.so libEGL.so.1.0
	install_custom_pc egl_dfb egl
	install_lib libGLESv2-${_backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${_backend}.so libVIVANTE.so
	install_lib directfb-1.7-4/gfxdrivers/libdirectfb_gal.so
	install_conf directfbrc
	return
}

install_core_x11() {
	install_lib libGAL-${_backend}.so libGAL.so
	install_lib libGAL_egl.dri.so libGAL_egl.so
	install_lib libEGL-${_backend}.so libEGL.so.1.0
	install_custom_pc egl_x11 egl
	install_lib libGLESv2-${_backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${_backend}.so libVIVANTE.so

	# X11 OpenGL GLX
	install_lib libGL.so.1.2
	link_lib libGL.so.1.2 libGL.so.1
	link_lib libGL.so.1 libGL.so
	install_custom_pc gl

	# DRI
	install_dri_driver vivante_dri.so
	return
}

install_core_wl() {
	install_lib libGAL-${_backend}.so libGAL.so
	install_lib libGAL_egl.${_backend}.so libGAL_egl.so
	install_lib libEGL-${_backend}.so libEGL.so.1.0
	install_custom_pc egl_wl egl
	install_pc wayland-egl # TODO: check what this does and if it is required
	install_lib libGLESv2-${_backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${_backend}.so libVIVANTE.so

	# Wayland libs
	install_lib libgc_wayland_protocol.so.0.0.0
	link_lib libgc_wayland_protocol.so.0.0.0 libgc_wayland_protocol.so.0
	link_lib libgc_wayland_protocol.so.0 libgc_wayland_protocol.so
	install_lib libgc_wayland_protocol.a
	install_pc gc_wayland_protocol

	install_lib libwayland-viv.so.0.0.0
	link_lib libwayland-viv.so.0.0.0 libwayland-viv.so.0
	link_lib libwayland-viv.so.0 libwayland-viv.so
	install_lib libwayland-viv.a
	install_pc wayland-viv

	# TODO: update paths in installed .pc-files
	return
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
	if [ "x${_backend}" = "xfb" ]; then
		mkdir -p "${_destdir}/opt/viv_samples"
		cp -rv "${SOURCESDIR}/opt/viv_samples/es20" "${_destdir}/opt/viv_samples/"
		cp -rv "${SOURCESDIR}/opt/viv_samples/tiger" "${_destdir}/opt/viv_samples/"
		cp -rv "${SOURCESDIR}/opt/viv_samples/vdk" "${_destdir}/opt/viv_samples/"
	fi

	return
}

install_tools() {
	install_bin gmem_info
	return
}

install_apitrace_nonx11() {
	install_bin apitrace
	install_bin eglretrace
	install_lib apitrace/wrappers/egltrace.so
	mkdir -p "${_destdir}/usr/lib/apitrace"
	cp -rv "${SOURCESDIR}/usr/lib/apitrace/scripts" "${_destdir}/${_libdir}/apitrace/"
	mkdir -p "${_destdir}/usr/share/doc/"
	cp -rv "${SOURCESDIR}/usr/share/doc/apitrace" "${_destdir}/usr/share/doc/"
	return
}

install_apitrace_x11() {
	install_apitrace_nonx11
	install_bin glretrace
	install_lib apitrace/wrappers/glxtrace.so
	return
}

#################################################################

# handle arguments and set default paths
usage() {
	echo Userspace installer for Vivante graphics driver
	echo Usage: $0 [OPTIONS]
	echo
	echo "	--backend       graphics backend (base|fb|dfb|x11|wl)"
	echo
	echo "	--fhw           floating-point hardware (hard|soft)"
	echo
	echo "	--destdir       installation prefix"
	echo "	--libdir        directory for libraries"
	echo "	--includedir	directory for header files"
	echo "	--dridir        directory for DRI drivers"
	echo "	--sysconfdir    directory for system-wide configuration files"
	echo "	--bindir        directory for binaries"
	echo
	echo "  --skip-cl       dont install OpenCL parts"
	echo
}

s=0
OPTIONS=`getopt -n "$0" -o "" -l "backend:,destdir:,libdir:,includedir:,dridir:,bindir:,sysconfdir:,fhw:,skip-cl" -- "$@"` || s=$?
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
skip_cl=no
eval set -- "$OPTIONS"
while true; do
	case $1 in
		--backend)
			_backend=$2
			shift 2
			;;
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

case $_backend in
  base)	;;
  fb)	;;
  dfb)	;;
  x11)	;;
  wl)	;;
  *)	echo "Backend ${_backend} is unknown!"
	exit 1
	;;
esac

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
	fslpkgname=imx-gpu-viv-5.0.11.p4.4-hfp.bin
	fslpkgchksum=5aa3dfe5b9362f9ee53615e0a56f9009
else
	fslpkgname=imx-gpu-viv-5.0.11.p4.4-sfp.bin
	fslpkgchksum=201398ab011b8765755fafb898efa77d
fi
fetch $fslpkgname $fslpkgchksum

# unpack the archive at the current location
unpack $fslpkgname

basedir="$PWD"
vivantebindir="$basedir/`basename $fslpkgname .bin`"
vivanteversion=5.0.11

# perform installation

SOURCESDIR="${vivantebindir}/gpu-core"
install_core_base
install_core_${_backend}

SOURCESDIR="${vivantebindir}/gpu-demos"
install_demos

SOURCESDIR="${vivantebindir}/g2d"
install_g2d

if [ "x${_backend}" = "xx11" ]; then
	SOURCESDIR="${vivantebindir}/apitrace/x11"
	install_apitrace_x11
else
	SOURCESDIR="${vivantebindir}/apitrace/non-x11"
	install_apitrace_nonx11
fi
