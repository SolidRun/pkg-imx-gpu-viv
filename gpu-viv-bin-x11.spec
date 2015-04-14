#
# spec file for package gpu-viv-bin
#
# Copyright (c) 2014-2015 Josua Mayer <josua@solid-run.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

%define blobpkg_name imx-gpu-viv-5.0.11.p4.4-hfp
%define blobpkg_md5 5aa3dfe5b9362f9ee53615e0a56f9009

# skip OpenCL on older distros (requires recent glibc)
%if 0%{?suse_version} > 0 && 0%{?suse_version} <= 1320
  %define skip_cl 1
%else
  %define skip_cl 0
%endif

Name: gpu-viv-bin-x11
Version: 5.0.11.p4.4
Release: 1
License: Freescale IP
Group: System/Libraries
Summary: Binary drivers for Vivante GPU
Source: gpu-viv-bin-%{version}.tar.gz
Source1: %{blobpkg_name}.bin
BuildRequires: pkgconfig

# provide the same libname Mesa does
# (vivante file is libGL.so.1.2)
Provides: libGL.so.1

%description
Provides the binary-only implementations of GPU libraries provided by Vivante.

%package devel
Group: Development/Libraries/C and C++
Summary: Backend-independent Vivante libs
Requires: gpu-viv-bin-x11 = %version
%description devel
T.O.D.O.

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%prep
%setup -q
chmod +x %{SOURCE1}
ln -sv %{SOURCE1} ./
%{SOURCE1} --auto-accept --force

%build

%install
./install.sh \
	--destdir "%{buildroot}" \
	--backend x11 \
	--dridir /usr/lib/dri \
%if %skip_cl
	--skip-cl \
%endif
	%{nop}

%files
%defattr(-,root,root)
/etc/Vivante.icd
/opt/fsl-samples
/usr/bin/*
/usr/lib/apitrace
/usr/lib/dri
/usr/lib/libEGL.so.*
/usr/lib/libg2d.so.*
/usr/lib/libGAL_egl.so
/usr/lib/libGAL.so
/usr/lib/libGLES_CL.so.*
/usr/lib/libGLES_CM.so.*
/usr/lib/libGLESv1_CL.so.*
/usr/lib/libGLESv1_CM.so.*
/usr/lib/libGLESv2.so.*
/usr/lib/libGLSLC.so
/usr/lib/libGL.so.*
/usr/lib/libOpenVG*.so
/usr/lib/libVDK.so
/usr/lib/libVIVANTE.so
/usr/lib/libVSC.so
/usr/share/doc/apitrace
%doc EULA.txt

%if ! %skip_cl
/usr/lib/libCLC.so
/usr/lib/libOpenCL.so
/usr/lib/libVivanteOpenCL.so
%endif

%files devel
%defattr(-,root,root)
/usr/include/*
/usr/lib/libEGL.so
/usr/lib/libg2d.so
/usr/lib/libGLES_CL.so
/usr/lib/libGLES_CM.so
/usr/lib/libGLESv1_CL.so
/usr/lib/libGLESv1_CM.so
/usr/lib/libGLESv2.so
/usr/lib/libGL.so
/usr/lib/pkgconfig/*.pc

%changelog
