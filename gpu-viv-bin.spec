#
# spec file for package gpu-viv-bin
#
# Copyright (c) 2014 Josua Mayer <josua@solid-run.com>
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

%define blobpkg_name gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp
%define blobpkg_md5 29a54f6e5bf889a00cd8ca85080af223

%define x11only 1

Name: gpu-viv-bin
Version: 3
Release: 1
License: Freescale IP
Group: System/Libraries
Summary: Binary drivers for Vivante GPU
Source: gpu-viv-bin-%{version}.tar.gz
Source1: %{blobpkg_name}.bin

%description
Provides the binary-only implementations of GPU libraries provided by Vivante.

%package common
Group: System/Libraries
Summary: Backend-independent Vivante libs
%description common
Provides the binary-only implementations of GPU libraries provided by Vivante using the Linux Framebuffer.

%post common
/sbin/ldconfig

%postun common
/sbin/ldconfig

%package common-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
%description common-devel
Provides development files to build against the GPU libraries provided by Vivante.

%package fb
Group: System/Libraries
Summary: Vivante libs for Framebuffer backend
%description fb
Provides the binary-only implementations of GPU libraries provided by Vivante using the Linux Framebuffer.

%post fb
/sbin/ldconfig

%postun fb
/sbin/ldconfig

%package fb-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
Requires: %{name}-common-devel
%description fb-devel
Provides development files to build against the GPU libraries provided by Vivante.

%package dfb
Group: System/Libraries
Summary: Vivante libs for DirectFB backend
%description dfb
Provides the binary-only implementations of GPU libraries provided by Vivante using DirectFB.

%post dfb
/sbin/ldconfig

%postun dfb
/sbin/ldconfig

%package dfb-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
Requires: %{name}-common-devel
%description dfb-devel
Provides development files to build against the GPU libraries provided by Vivante.

%package x11
Group: System/Libraries
Summary: Vivante libs for X11 backend
Provides: libGL.so.1
%description x11
Provides the binary-only implementations of GPU libraries provided by Vivante using X11.

%post x11
/sbin/ldconfig

%postun x11
/sbin/ldconfig

%package x11-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
Requires: %{name}-common-devel
%description x11-devel
Provides development files to build against the GPU libraries provided by Vivante.

%prep
%setup -q
chmod +x %{SOURCE1}
ln -sv %{SOURCE1} ./
%{SOURCE1} --auto-accept --force

%build
./install.sh temp-base base
./install.sh temp-fb fb
./install.sh temp-dfb dfb
./install.sh temp-x11 x11

%install
cp -rv temp-base/* %{buildroot}/
cp -rv temp-x11/* %{buildroot}/

%files common
%defattr(-,root,root)
/usr/lib/libCLC.so
/usr/lib/libGLES_CL.so
/usr/lib/libGLES_CM.so
/usr/lib/libGLESv1_CL.so.*
/usr/lib/libGLESv1_CM.so.*
/usr/lib/libGLSLC.so
/usr/lib/libOpenCL.so
/usr/lib/libOpenVG*.so
/usr/lib/libVDK.so
%doc EULA.txt

%files common-devel
%defattr(-,root,root)
/usr/include/*
/usr/lib/libEGL.so
/usr/lib/libGLESv1_CL.so
/usr/lib/libGLESv1_CM.so
/usr/lib/libGLESv2.so
%exclude /usr/lib/pkgconfig/egl.pc
%exclude /usr/lib/pkgconfig/gl.pc
/usr/lib/pkgconfig/*.pc

%if 0%{x11only} == 0
%files fb
%defattr(-,root,root)
/usr/lib/libEGL.so.*
/usr/lib/libGAL.so
/usr/lib/libGLESv2.so.*
/usr/lib/libVIVANTE.so

%files fb-devel
%defattr(-,root,root)
/usr/lib/pkgconfig/egl.pc

%files dfb
%defattr(-,root,root)
/usr/lib/libEGL.so.*
/usr/lib/libGAL.so
/usr/lib/libGLESv2.so.*
/usr/lib/libVIVANTE.so
%dir /usr/lib/directfb-1.6-0
%dir /usr/lib/directfb-1.6-0/gfxdrivers
/usr/lib/directfb-1.6-0/gfxdrivers/*.so

%files dfb-devel
%defattr(-,root,root)
/usr/lib/pkgconfig/egl.pc
%endif

%files x11
%defattr(-,root,root)
/usr/lib/libEGL.so.*
/usr/lib/libGAL.so
/usr/lib/libGLESv2.so.*
/usr/lib/libVIVANTE.so
/usr/lib/libGL.so.*
%dir /usr/lib/dri
/usr/lib/dri/vivante_dri.so

%files x11-devel
%defattr(-,root,root)
/usr/lib/libGL.so
/usr/lib/pkgconfig/egl.pc
/usr/lib/pkgconfig/gl.pc

%changelog
