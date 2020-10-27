# work-around occasionally-ignored ld.so.conf.d
export LD_LIBRARY_PATH=/usr/lib/galcore

# select default gl-provider for libcogl (heavily used by gnome)
export COGL_DRIVER=gles2
