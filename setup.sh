export CLANG_PREBUILT_BIN=$HOME/code/android/gclang/clang-4691093/bin/
export CROSS_COMPILE=aarch64-linux-android-
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export GCC_TOOLCHAIN=$HOME/code/android/google49
export ARCH=arm64
export LD_LIBRARY_PATH=$HOME/code/android/gclang/clang-4691093/lib64:$LD_LIBRARY_PATH
export PATH=$CLANG_PREBUILT_BIN:$GCC_TOOLCHAIN/bin:$PATH
export REAL_COMPILER=clang
export SUBARCH=arm64
export KBUILD_BUILD_USER=enlight
export KBUILD_BUILD_HOST=universe
export TOOL_CHAIN_PATH=$HOME/code/android/google49/bin/aarch64-linux-android-
export CLANG_TCHAIN=$CLANG_PREBUILT_BIN/clang
export CLANG_VERSION="$(${CLANG_TCHAIN} --version|head -n1|cut -d'(' -f1,4)"
export REAL_COMPILER=clang

alias make="make CC=$CLANG_TCHAIN CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$TOOL_CHAIN_PATH KBUILD_COMPILER_STRING="${CLANG_VERSION}" HOSTCC=$CLANG_TCHAIN"

# helpers
mkzip() {
    rm anykernel/Image.gz-dtb
    cp arch/arm64/boot/Image.gz-dtb anykernel/
    zip -r enlight_kernel.zip anykernel/*
    echo 'Done. Output is enlight_kernel.zip'
}
