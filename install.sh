#!/bin/bash -e

install_lib() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	install -v -m755 -D "${vivantebindir}/usr/lib/${oldname}" "${destdir}/usr/lib/${newname}"
}

link_lib() {
	# in case the destination already exists it has to be overwritten
	# if the destination exists and is a file, or a symlink
	if [ -e "${destdir}/usr/lib/${2}" ] || [ -h "${destdir}/usr/lib/${2}" ]; then
		t=0
		rm -vf "${destdir}/usr/lib/${2}" || t=$?

		if [ "x${t}" != "x0" ]; then
			echo "ERROR: ${destdir}/usr/lib/${2} already exists and can not be deleted"
			return 1
		fi
	fi

	# make sure the destination directory exists
	mkdir -p ${destdir}/usr/lib/

	# create the link
	t=0
	ln -sv "${1}" "${destdir}/usr/lib/${2}" || t=$?

	return $t
}

install_headers() {
	# TODO: what ifdestination already exists?

	mkdir -p ${destdir}/usr/include/
	cp -rv "${vivantebindir}/usr/include/${1}" "${destdir}/usr/include/"
	find "${destdir}/usr/include/${1}" -type f -exec chmod 644 {} \;
	find "${destdir}/usr/include/${1}" -type d -exec chmod 755 {} \;
}

install_header() {
	install -v -m644 -D "${vivantebindir}/usr/include/${1}" "${destdir}/usr/include/${1}"
}

format_pc() {
	name="${1}"
	includedir="${2}"
	libdir="${3}"
	version="${4}"

	cp -v "${basedir}/${name}.pc.in" "${basedir}/${name}.pc"
	sed -e "s;@INCLUDEDIR@;${includedir};g" \
	    -e "s;@LIBDIR@;${libdir};g" \
	    -e "s;@VERSION@;${version};g" \
	    -i "${basedir}/${name}.pc"

	return 0
}

install_pc() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	mkdir -p ${destdir}/usr/lib/pkgconfig/
	install -v -m644 "${vivantebindir}/usr/lib/pkgconfig/${oldname}.pc" "${destdir}/usr/lib/pkgconfig/${newname}.pc"
	return 0
}

install_custom_pc() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	# generate .pc if .in exists
	if [ -e "${basedir}/${oldname}.pc.in" ]; then
		format_pc "${oldname}" /usr/include/ /usr/lib/ "${vivanteversion}"
	fi

	if [ ! -e "${basedir}/${oldname}.pc" ]; then
		echo "${basedir}/${oldname}.pc not found!"
		return 1
	fi

	mkdir -p ${destdir}/usr/lib/pkgconfig/
	install -v -m644 "${basedir}/${oldname}.pc" "${destdir}/usr/lib/pkgconfig/${newname}.pc"

	return 0
}

#################################################################

fetch() {
	name=$1
	chksum=$2

	# check existing file
	t=0
	chksum $name $chksum || t=$?
	if [ "x$t" = "x0" ]; then
		echo "$name exists already and MD5 matches. Keeping the file."
		return 0
	else
		if [ "x$t" = "x2" ]; then
			echo "$name exists already but MD5 does not match. Deleting the file."
			rm -v $name
		fi
			# else t=1 >> file doesn't exist yet
	fi

	# try all mirrors
	for mirror in $MIRRORS; do

		# download
		t=0
		wget $mirror/$name || t=$?

		# handle wget return status
		if [ "x$t" = "x0" ]; then
			echo "$name downloaded."
			break
		else
			echo "Download of $name failed. Cleaning up."
			rm -fv $name
			continue
		fi

	done

	if  [ ! -f "$name" ]; then
		echo "Download of $name failed."
		return 1
	fi

	# check MD5 again
	t=0
	chksum $name $chksum || t=$?

	if [ "x$t" != "x0" ]; then
		echo "MD5 of downloaded file does not match! Keeping it anyway."
		return 1
	fi

	return 0
}

chksum() {
	file=$1
	chksum=$2

	if [ ! -e "$file" ]; then
		return 1
	fi

	mysum=`md5sum $file | cut -d ' ' -f 1`
	if [ "$mysum" == "$chksum" ]; then
		return 0
	else
		return 2
	fi
}

#################################################################

unpack() {
	filename="$1"

	# guess the name of output directory
	outdir=`basename ${filename} .bin`

	# if the folder already exists, don't bother
	if [ -d "${outdir}" ]; then
		echo "archive has already been unpacked!"
		return 0
	fi

	# actually unpack it
	"${SHELL}" "${filename}" --auto-accept --force
	return $?
}

#################################################################

install_base() {
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
	install_lib libGLES_CL.so
	install_lib libGLES_CM.so
	install_headers GLES

	# OpenGL-ES 1.1
	install_lib libGLESv1_CL.so libGLESv1_CL.so.1.1.0
	link_lib libGLESv1_CL.so.1.1.0 libGLESv1_CL.so.1
	link_lib libGLESv1_CL.so.1 libGLESv1_CL.so
	install_lib libGLESv1_CM.so libGLESv1_CM.so.1.1.0
	link_lib libGLESv1_CM.so.1.1.0 libGLESv1_CM.so.1
	link_lib libGLESv1_CM.so.1 libGLESv1_CM.so
	install_custom_pc glesv1_cm

	# OpenGL-ES 2.0
	# libGLESv2.so.2.0.0 backend-dependent
	link_lib libGLESv2.so.2.0.0 libGLESv2.so.2
	link_lib libGLESv2.so.2 libGLESv2.so
	install_headers GLES2
	install_custom_pc glesv2

	# GL Shader Compiler
	install_lib libGLSLC.so

	# OpenVG
	install_lib libOpenVG_355.so
	install_lib libOpenVG_3D.so
	link_lib libOpenVG_3D.so libOpenVG.so
	install_headers VG
	install_custom_pc vg

	# OpenCL (only GC2000)
	install_lib libOpenCL.so
	install_lib libCLC.so
	install_headers CL

	# VDK
	install_lib libVDK.so
	install_header gc_vdk.h
	install_header gc_vdk_hal.h
	install_header gc_vdk_types.h
	install_header vdk.h
}

install_fb() {
	install_lib libGAL-${backend}.so libGAL.so
	install_lib libEGL-${backend}.so libEGL.so.1.0
	install_custom_pc egl_fb egl
	install_lib libGLESv2-${backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${backend}.so libVIVANTE.so
}

install_dfb() {
	install_lib libGAL-${backend}.so libGAL.so
	install_lib libEGL-${backend}.so libEGL.so.1.0
	install_custom_pc egl_dfb egl
	install_lib libGLESv2-${backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${backend}.so libVIVANTE.so
	install_lib directfb-1.6-0/gfxdrivers/libdirectfb_gal.so
	return
}

install_x11() {
	install_lib libGAL-${backend}.so libGAL.so
	install_lib libEGL-${backend}.so libEGL.so.1.0
	install_custom_pc egl_x11 egl
	install_lib libGLESv2-${backend}.so libGLESv2.so.2.0.0
	install_lib libVIVANTE-${backend}.so libVIVANTE.so

	# X11 OpenGL GLX
	install_lib libGL.so libGL.so.1.2
	link_lib libGL.so.1.2 libGL.so.1
	link_lib libGL.so.1 libGL.so
	install_custom_pc gl

	# DRI
	install_lib dri/vivante_dri.so
}

install_wl() {
	# TODO
	return
}

install_demos() {
	mkdir -p "${destdir}/opt/"
	cp -rv "${vivantebindir}/opt/viv_samples" "${destdir}/opt/"
	return
}

#################################################################

usage() {
	echo "Freescale Vivante Userspace Installer"
	echo "Usage: ${0} <destination> <backend>"
	echo "Backends: fb dfb x11" # TODO: wl
}

# take 2 arguments, destination and backend
if [ "x${#}" != "x2" ]; then
	usage
	exit 1
fi

destdir="${1}"
if [ ! -d "${destdir}" ]; then
	echo "Warning: ${destdir} does not exist yet, going to create it."
fi

backend="${2}"
case $backend in
  fb)	;;
  dfb)	;;
  x11)	;;
#  wl)	;;
  *)	echo "Backend ${backend} is unknown!"
	exit 1
	;;
esac

#################################################################

echo "Going to install Freescale Vivante userspace 3.10.17-1.0.1"

# download the vivante binary package
MIRRORS="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/ http://download.ossystems.com.br/bsp/freescale/source/"
fetch gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp.bin d729db01e3eec3384e310cd3507761ce
# fetch gpu-viv-bin-mx6q-3.10.17-1.0.1-sfp.bin 55788f48a222b430a8b76856ac6fa636

# unpack the archive at the current location
unpack gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp.bin

basedir="$PWD"
vivantebindir="$PWD/gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp"
vivanteversion=1.0.1

install_base
install_${backend}
#install_demos
