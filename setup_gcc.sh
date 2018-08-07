#export CROSS_COMPILE=$HOME/code/android/google49/bin/aarch64-linux-android-
#export CROSS_COMPILE=$HOME/code/android/gclang/clang-4691093/bin/
#export CROSS_COMPILE=$HOME/code/android/linaro731/bin/aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64

export KBUILD_BUILD_USER=velocity
export KBUILD_BUILD_HOST=kernel

jobs=8

export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

unalias cat > /dev/null 2>&1
unalias zip > /dev/null 2>&1

cc_ver="$(${CROSS_COMPILE}gcc --version|head -n1|cut -d'(' -f2|tr -d ')'|awk '{$5=""; print $0}'|sed -e 's/[[:space:]]*$//')"
MAKEFLAGS=("KBUILD_COMPILER_STRING=${cc_ver}")

# helpers
source helpers.sh
