#project('imx-gpu-wrappers', 'c')

# dependencies
cc = meson.get_compiler('c')
dl_dep = cc.find_library('dl', required : false)

# Implib libgbm1 glue
implib_gen = find_program('implib/implib-gen.py')
libgbm1_glue = custom_target('libgbm1-glue',
    input: 'libgbm1.symbols',
    output: ['libgbm1.init.c', 'libgbm1.tramp.S'], 
    command: [implib_gen, '--symbol-list', '@INPUT@', '--target', host_machine.cpu_family(), '--no-lazy-load', '--dlopen-callback', 'load_libgbm1', '--outdir', '@OUTDIR@', 'libgbm1'],
)

# libgbm1 wrapper
libgbm_sources = ['libgbm1.c', libgbm1_glue]
libgbm = shared_library('gbm', libgbm_sources, soversion : '1', version: '1.0.0', dependencies: dl_dep)
