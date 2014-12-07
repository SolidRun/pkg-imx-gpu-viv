%define blobpkg_name gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp
%define blobpkg_md5 29a54f6e5bf889a00cd8ca85080af223

%define x11only 1

Name: gpu-viv-bin
Version: 3
Release: 1
License: Proprietary
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
%config /etc/ld.so.conf.d/0galcore.conf
%dir /usr/lib/galcore
/usr/lib/galcore/libCLC.so
/usr/lib/galcore/libGLES_CL.so
/usr/lib/galcore/libGLES_CM.so
/usr/lib/galcore/libGLESv1_CL.so.*
/usr/lib/galcore/libGLESv1_CM.so.*
/usr/lib/galcore/libGLSLC.so
/usr/lib/galcore/libOpenCL.so
/usr/lib/galcore/libOpenVG*.so
/usr/lib/galcore/libVDK.so

%files common-devel
%defattr(-,root,root)
/usr/include/*
/usr/lib/galcore/libEGL.so
/usr/lib/galcore/libGLESv1_CL.so
/usr/lib/galcore/libGLESv1_CM.so
/usr/lib/galcore/libGLESv2.so
%exclude /usr/lib/pkgconfig/egl.pc
%exclude /usr/lib/pkgconfig/gl.pc
/usr/lib/pkgconfig/*.pc

%if 0%{x11only} == 0
%files fb
%defattr(-,root,root)
/usr/lib/galcore/libEGL.so.*
/usr/lib/galcore/libGAL.so
/usr/lib/galcore/libGLESv2.so.*
/usr/lib/galcore/libVIVANTE.so

%files fb-devel
%defattr(-,root,root)
/usr/lib/pkgconfig/egl.pc

%files dfb
%defattr(-,root,root)
/usr/lib/galcore/libEGL.so.*
/usr/lib/galcore/libGAL.so
/usr/lib/galcore/libGLESv2.so.*
/usr/lib/galcore/libVIVANTE.so
%dir /usr/lib/directfb-1.6-0
%dir /usr/lib/directfb-1.6-0/gfxdrivers
/usr/lib/directfb-1.6-0/gfxdrivers/*.so

%files dfb-devel
%defattr(-,root,root)
/usr/lib/pkgconfig/egl.pc
%endif

%files x11
%defattr(-,root,root)
%dir /usr/lib/galcore
/usr/lib/galcore/libEGL.so.*
/usr/lib/galcore/libGAL.so
/usr/lib/galcore/libGLESv2.so.*
/usr/lib/galcore/libVIVANTE.so
/usr/lib/galcore/libGL.so.*
%dir /usr/lib/dri
/usr/lib/dri/vivante_dri.so

%files x11-devel
%defattr(-,root,root)
/usr/lib/galcore/libGL.so
/usr/lib/pkgconfig/egl.pc
/usr/lib/pkgconfig/gl.pc

%changelog
