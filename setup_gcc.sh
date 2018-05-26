#export CROSS_COMPILE=$HOME/code/android/google49/bin/aarch64-linux-android-
#export CROSS_COMPILE=$HOME/code/android/gclang/clang-4691093/bin/
export CROSS_COMPILE=$HOME/code/android/linaro731/bin/aarch64-linux-gnu-
export ARCH=arm64

jobs=10

export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

unalias cat > /dev/null 2>&1
unalias zip > /dev/null 2>&1

MAKEFLAGS=()

# helpers
source helpers.sh
