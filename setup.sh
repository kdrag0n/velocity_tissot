# Toolchain paths
tc_clang=$HOME/code/android/dtc/out/7.0
tc_gcc=$HOME/code/android/linaro731

# Do not edit below this point
# -----------------------------

export CLANG_PREBUILT_BIN=$tc_clang/bin/
export CROSS_COMPILE=aarch64-linux-gnu-
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export GCC_TOOLCHAIN=$tc_gcc
export ARCH=arm64
export LD_LIBRARY_PATH=$tc_clang/lib64:$LD_LIBRARY_PATH
export PATH=$CLANG_PREBUILT_BIN:$GCC_TOOLCHAIN/bin:$PATH
export REAL_COMPILER=clang
export SUBARCH=arm64
export KBUILD_BUILD_USER=enlight
export KBUILD_BUILD_HOST=universe
export TOOL_CHAIN_PATH=$tc_gcc/bin/aarch64-linux-gnu-
export CLANG_TCHAIN=$CLANG_PREBUILT_BIN/clang
export CLANG_VERSION="$(${CLANG_TCHAIN} --version|head -n1|cut -d'(' -f1,4)"
export REAL_COMPILER=clang

export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

alias make="make CC=$CLANG_TCHAIN CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$TOOL_CHAIN_PATH KBUILD_COMPILER_STRING=\"${CLANG_VERSION}\" HOSTCC=$CLANG_TCHAIN"

# helpers
mkzip() {
    rm anykernel/Image.gz-dtb
    rm enlight_kernel.zip
    cat arch/arm64/boot/Image.gz arch/arm/boot/dts/qcom/msm8953-qrd-sku3.dtb > anykernel/Image.gz-dtb
    cd anykernel
    zip -r ../enlight_kernel.zip *
    cd ..
    echo 'Done. Output is enlight_kernel.zip'
}

cleanbuild() {
    make clean && make -j && mkzip
}

incbuild() {
    make -j && mkzip
}
