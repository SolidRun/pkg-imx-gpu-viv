#!/bin/bash

##############
# Downloader #
##############

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
	if [ "$mysum" = "$chksum" ]; then
		return 0
	else
		return 2
	fi
}

###########################
# selfextractpkg unpacker #
###########################

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

####################
# install wrappers #
####################

# common environment variables:
# SOURCESDIR
# _destdir
# _libdir
# _bindir
# _dridir
# _sysconfdir
#

install_lib() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	install -v -m755 -D "${SOURCESDIR}/usr/lib/${oldname}" "${_destdir}/${_libdir}/${newname}"
}

install_bin() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	install -v -m755 -D "${SOURCESDIR}/usr/bin/${oldname}" "${_destdir}/${_bindir}/${newname}"
}

install_dri_driver() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	install -v -m755 -D "${SOURCESDIR}/usr/lib/dri/${oldname}" "${_destdir}/${_dridir}/${newname}"
}

install_conf() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		newname="${oldname}"
	fi

	install -v -m755 -D "${SOURCESDIR}/etc/${oldname}" "${_destdir}/${_sysconfdir}/${newname}"
}

link_lib() {
	# in case the destination already exists it has to be overwritten
	# if the destination exists and is a file, or a symlink
	if [ -e "${_destdir}/${_libdir}/${2}" ] || [ -h "${_destdir}/${_libdir}/${2}" ]; then
		t=0
		rm -vf "${_destdir}/${_libdir}/${2}" || t=$?

		if [ "x${t}" != "x0" ]; then
			echo "ERROR: ${_destdir}/${_libdir}/${2} already exists and can not be deleted"
			return 1
		fi
	fi

	# make sure the destination directory exists
	mkdir -p ${_destdir}/${_libdir}

	# create the link
	t=0
	ln -sv "${1}" "${_destdir}/${_libdir}/${2}" || t=$?

	return $t
}

install_headers() {
	# TODO: what if destination already exists?

	mkdir -p ${_destdir}/${_includedir}
	cp -rv "${SOURCESDIR}/usr/include/${1}" "${_destdir}/${_includedir}/"
	find "${_destdir}/${_includedir}/${1}" -type f -exec chmod 644 {} \;
	find "${_destdir}/${_includedir}/${1}" -type d -exec chmod 755 {} \;
}

install_header() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		destname="${oldname}"
	fi
	install -v -m644 -D "${SOURCESDIR}/usr/include/${oldname}" "${_destdir}/${_includedir}/${newname}"
}

install_custom_header() {
	oldname="${1}"
	newname="${2}"
	if [ -z "${newname}" ]; then
		destname="${oldname}"
	fi
	install -v -m644 -D "${basedir}/${oldname}" "${_destdir}/${_includedir}/${newname}"
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

	mkdir -p ${_destdir}/${_libdir}/pkgconfig/
	install -v -m644 "${SOURCESDIR}/usr/lib/pkgconfig/${oldname}.pc" "${_destdir}/${_libdir}/pkgconfig/${newname}.pc"
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
		format_pc "${oldname}" ${_includedir} ${_libdir} "${vivanteversion}"
	fi

	if [ ! -e "${basedir}/${oldname}.pc" ]; then
		echo "${basedir}/${oldname}.pc not found!"
		return 1
	fi

	mkdir -p ${_destdir}/${_libdir}/pkgconfig/
	install -v -m644 "${basedir}/${oldname}.pc" "${_destdir}/${_libdir}/pkgconfig/${newname}.pc"

	return 0
}
