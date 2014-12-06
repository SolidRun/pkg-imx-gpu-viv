%define blobpkg_name gpu-viv-bin-mx6q-3.10.17-1.0.1-hfp
%define blobpkg_md5 29a54f6e5bf889a00cd8ca85080af223

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

%package x11
Group: System/Libraries
Summary: Binary drivers for Vivante GPU
%description x11
Provides the binary-only implementations of GPU libraries provided by Vivante.

%package x11-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
%description x11-devel
Provides development files to build against the GPU libraries provided by Vivante.

%package fb
Group: System/Libraries
Summary: Binary drivers for Vivante GPU
%description fb
Provides the binary-only implementations of GPU libraries provided by Vivante.

%package fb-devel
Group: Development/Languages/C and C++
Summary: Development files for Vivante GPU drivers
%description fb-devel
Provides development files to build against the GPU libraries provided by Vivante.

%prep
%setup -q
chmod +x %{SOURCE1}
ln -sv %{SOURCE1} ./
%{SOURCE1} --auto-accept --force

%build x11
./install.sh temp x11

%build fb
./install.sh temp fb

%install
cp -r temp/* %{buildroot}

%files x11
%defattr(-,root,root)
%config /etc/ld.so.conf.d/0galcore.conf
%dir /usr/lib/galcore
/usr/lib/galcore/libCLC.so
/usr/lib/galcore/libEGL.so.*
/usr/lib/galcore/libGAL.so
/usr/lib/galcore/libGLES_CL.so
/usr/lib/galcore/libGLES_CM.so
/usr/lib/galcore/libGLESv1_CL.so.*
/usr/lib/galcore/libGLESv1_CM.so.*
/usr/lib/galcore/libGLESv2.so.*
/usr/lib/galcore/libGLSLC.so
/usr/lib/galcore/libOpenCL.so
/usr/lib/galcore/libOpenVG*.so
/usr/lib/galcore/libVDK.so
/usr/lib/galcore/libVIVANTE.so
/usr/lib/galcore/libGL.so.*
%dir /usr/lib/dri
/usr/lib/dri/vivante_dri.so

#%%dir /usr/lib/directfb-1.6-0
#%%dir /usr/lib/directfb-1.6-0/gfxdrivers
#/usr/lib/directfb-1.6-0/gfxdrivers/*.so

%files x11-devel
/usr/include/*
/usr/lib/galcore/libEGL.so
/usr/lib/galcore/libGLESv1_CL.so
/usr/lib/galcore/libGLESv1_CM.so
/usr/lib/galcore/libGLESv2.so
/usr/lib/pkgconfig/*.pc
/usr/lib/galcore/libGL.so

%files fb
%defattr(-,root,root)
%config /etc/ld.so.conf.d/0galcore.conf
%dir /usr/lib/galcore
/usr/lib/galcore/libCLC.so
/usr/lib/galcore/libEGL.so.*
/usr/lib/galcore/libGAL.so
/usr/lib/galcore/libGLES_CL.so
/usr/lib/galcore/libGLES_CM.so
/usr/lib/galcore/libGLESv1_CL.so.*
/usr/lib/galcore/libGLESv1_CM.so.*
/usr/lib/galcore/libGLESv2.so.*
/usr/lib/galcore/libGLSLC.so
/usr/lib/galcore/libOpenCL.so
/usr/lib/galcore/libOpenVG*.so
/usr/lib/galcore/libVDK.so
/usr/lib/galcore/libVIVANTE.so

%files fb-devel
%defattr(-,root,root)
/usr/include/*
/usr/lib/galcore/libEGL.so
/usr/lib/galcore/libGLESv1_CL.so
/usr/lib/galcore/libGLESv1_CM.so
/usr/lib/galcore/libGLESv2.so
/usr/lib/pkgconfig/*.pc

%changelog
