/*
 * Copyright 2019 Josua Mayer <josua@solid-run.com>
 **/

#include <dlfcn.h>
#include <stdio.h>

void *load_libgbm1(const char *lib_name) {
    const char *gbm_viv_path = "/usr/lib/vivante/gbm_viv.so";
    const char *libgbm_path = "/usr/lib/vivante/libgbm.so";
    void *gbm_viv = 0;
    void *libgbm = 0;

    gbm_viv = dlopen(gbm_viv_path, RTLD_LAZY | RTLD_GLOBAL);
    if(gbm_viv == 0) {
        fprintf(stderr, "libgbm1: failed to load %s: %s\n", gbm_viv_path, dlerror());
        goto out;
    }
    libgbm = dlopen(libgbm_path, RTLD_LAZY | RTLD_GLOBAL);
    if(libgbm == 0) {
        fprintf(stderr, "libgbm1: failed to load %s: %s\n", libgbm_path, dlerror());
        goto out;
    }

out:
    return libgbm;
}
