project('imx-gpu-viv', 'c')

# dummy libraries for the backend-dependent libs required by the indep package;
# dpkg-shlibdeps will otherwise add one backend package as dependency to all of them
shared_library('EGL', [], soversion: '1')
shared_library('GAL', [])
shared_library('GL', [], soversion: '1')
shared_library('GLESv2', [], soversion: '2')
shared_library('VDK', [], soversion: '1')
shared_library('vulkan', [], soversion: '1')

# use custom install script (replaces default install steps)
meson.add_install_script('install.sh', '--skip-alternatives', '--arch', host_machine.cpu_family(), '--dridir', join_paths(get_option('prefix'), get_option('libdir'), 'dri'))

# profile.d script
install_data(sources: 'vivante.profile.sh', rename: 'vivante.sh', install_dir: '/etc/profile.d')

# ld.so.conf
install_data(sources: 'vivante.ld.so.conf', rename: '0vivante.conf', install_dir: '/etc/ld.so.conf.d')

# wrappers
subdir('wrappers')

