/*
 * Copyright 2019 Josua Mayer <josua@solid-run.com>
 **/

#include <dlfcn.h>
#include <stdio.h>

void *load_libwaylandegl1(const char *lib_name) {
    const char *libegl1_path = "/usr/lib/galcore/wl/libEGL.so.1";
    void *libegl1 = 0;

    libegl1 = dlopen(libegl1_path, RTLD_LAZY | RTLD_GLOBAL);
    if(libegl1 == 0) {
        fprintf(stderr, "libwayland-egl1: failed to load %s: %s\n", libegl1_path, dlerror());
        goto out;
    }

out:
    return libegl1;
}
