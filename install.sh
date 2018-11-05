#!/bin/bash -e

source functions.inc

#################################################################

# Vivante core graphics libraries
install_core() {
	# GAL
	install_vivante_lib libGAL-fb.so
	install_vivante_lib libGAL-wl.so
	install_vivante_lib libGAL-x11.so
	install_header HAL

	# VSC
	install_vivante_lib libVSC.so

	# EGL
	install_vivante_lib libEGL-fb.so
	install_vivante_lib libEGL-wl.so
	install_vivante_lib libEGL-x11.so
	install_header EGL
	install_header KHR
	install_pc egl

	# GLES
	install_vivante_lib libGLES_CL.so.1.1.0
	install_vivante_lib libGLESv1_CM.so.1.1.0
	install_vivante_lib libGLESv1_CL.so.1.1.0
	install_vivante_lib libGLESv2-fb.so
	install_vivante_lib libGLESv2-wl.so
	install_vivante_lib libGLESv2-x11.so
	install_vivante_lib libGLSLC.so
	install_header GLES
	install_header GLES2
	install_header GLES3
	install_pc glesv1_cm
	install_pc glesv2

	# DRI
	install_vivante_lib libGL.so.1.2
	install_dri_driver vivante_dri.so
	install_header GL

	# OpenVG
	install_vivante_lib libOpenVG.2d.so
	install_vivante_lib libOpenVG.3d.so
	link_vivante_lib libOpenVG.3d.so libOpenVG.so
	install_header VG
	install_pc vg

	# OpenCL
	install_vivante_lib libCLC.so
	install_vivante_lib libLLVM_viv.so
	install_vivante_lib libOpenCL.so
	install_vivante_lib libVivanteOpenCL.so
	install_header CL
	install_conf Vivante.icd OpenCL/vendors/Vivante.icd

	# VDK
	install_vivante_lib libVDK-fb.so
	install_vivante_lib libVDK-wl.so
	install_vivante_lib libVDK-x11.so
	install_header vdk.h
	install_header gc_vdk.h
	install_header gc_vdk_types.h

	# Vivante Wayland
	install_lib libgc_wayland_protocol.a
	install_lib libgc_wayland_protocol.so.0.0.0
	link_lib libgc_wayland_protocol.so.0.0.0 libgc_wayland_protocol.so.0
	link_lib libgc_wayland_protocol.so.0 libgc_wayland_protocol.so
	install_pc gc_wayland_protocol
	install_lib libwayland-viv.a
	install_lib libwayland-viv.so.0.0.0
	link_lib libwayland-viv.so.0.0.0 libwayland-viv.so.0
	link_lib libwayland-viv.so.0 libwayland-viv.so
	install_header wayland-viv
	install_pc wayland-viv

	# gbm
	install_vivante_lib gbm_viv.so
	install_header gbm.h
	install_pc gbm

	return 0
}

install_demos() {
	mkdir -p "${_destdir}/opt/viv_samples"

	# OpenCL demos
	cp -rv "${SOURCESDIR}/opt/viv_samples/cl11" "${_destdir}/opt/viv_samples/"

	# Graphics demos
	cp -rv "${SOURCESDIR}/opt/viv_samples/es20" "${_destdir}/opt/viv_samples/"
	cp -rv "${SOURCESDIR}/opt/viv_samples/tiger" "${_destdir}/opt/viv_samples/"
	cp -rv "${SOURCESDIR}/opt/viv_samples/vdk" "${_destdir}/opt/viv_samples/"

	return 0
}

install_tools() {
	_SOURCESDIR="${SOURCESDIR}"
	SOURCESDIR="${SOURCESDIR}/gmem-info"
	install_bin gmem_info
	return 0
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
install_core

# patch headers
find ${_destdir}/${_includedir} -type f -exec sed -i "s;defined(LINUX);defined(__linux__);g" {} \;

SOURCESDIR="${vivantebindir}/gpu-tools"
install_tools

SOURCESDIR="${vivantebindir}/gpu-demos"
install_demos
