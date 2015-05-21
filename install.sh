#!/bin/bash -e

source functions.inc

#################################################################

# Vivante core graphics libraries
install_core_base() {
	# Vivante GPU HAL
	for bg in fb dfb wl; do
		install_lib libGAL-$bg.so imx-gpu-viv-$bg/libGAL.so
		install_lib libGAL_egl.$bg.so imx-gpu-viv-$bg/libGAL_egl.so
	done
	install_lib libGAL-x11.so imx-gpu-viv-x11/libGAL.so
	install_lib libGAL_egl.dri.so imx-gpu-viv-x11/libGAL_egl.so
	link_lib imx-gpu-viv/libGAL.so libGAL.so
	link_lib imx-gpu-viv/libGAL_egl.so libGAL_egl.so
	install_headers HAL

	# Khronos shared headers
	install_headers KHR

	# EGL
	link_lib libEGL.so.1.0 libEGL.so.1.0.0 # compatibility symlink to the Mesa soname of libEGL
	for bg in fb dfb wl x11; do
		install_lib libEGL-$bg.so imx-gpu-viv-$bg/libEGL.so.1.0
	done
	link_lib imx-gpu-viv/libEGL.so.1.0 libEGL.so.1.0
	install_custom_pc egl_fb ../imx-gpu-viv-fb/egl
	install_custom_pc egl_dfb ../imx-gpu-viv-dfb/egl
	install_custom_pc egl_wl ../imx-gpu-viv-wl/egl
	install_custom_pc egl_x11 ../imx-gpu-viv-x11/egl
	link_lib ../imx-gpu-viv/egl pkgconfig/egl.pc # make more readable
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
	for bg in fb dfb wl x11; do
		install_lib libGLESv2-$bg.so imx-gpu-viv-$bg/libGLESv2.so.2.0.0
	done
	link_lib imx-gpu-viv/libGLESv2.so.2.0.0 libGLESv2.so.2.0.0
	link_lib libGLESv2.so.2.0.0 libGLESv2.so.2
	link_lib libGLESv2.so.2 libGLESv2.so
	install_headers GLES2
	install_custom_pc glesv2

	# OpenGL-ES 3.0
	# part of libGLESv2.so
	install_headers GLES3

	# GL Shader Compiler
	install_lib libGLSLC.so

	# OpenVG
	install_lib libOpenVG.2d.so
	install_lib libOpenVG.3d.so
	link_lib libOpenVG.3d.so libOpenVG.so
	install_headers VG
	install_custom_pc vg
	# TODO: alternative for VG?

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
	for bg in fb dfb wl x11; do
		install_lib libVIVANTE-$bg.so imx-gpu-viv-$bg/libVIVANTE.so
	done
	link_lib imx-gpu-viv/libVIVANTE.so libVIVANTE.so

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
	install_lib libGL.so.1.2
	link_lib libGL.so.1.2 libGL.so.1
	link_lib libGL.so.1 libGL.so
	install_custom_pc gl

	# DRI
	install_dri_driver vivante_dri.so
	return
}

install_core_wl() {
	install_custom_pc wayland-egl

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

install_core_alternatives() {
	update-alternatives --remove-all vivante
	for bg in fb dfb wl x11; do
		update-alternatives --install /usr/lib/imx-gpu-viv vivante /usr/lib/imx-gpu-viv-$bg 10
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
install_core_fb
install_core_dfb
install_core_wl
install_core_x11
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
