export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64

export KBUILD_BUILD_USER=velocity
export KBUILD_BUILD_HOST=kernel

jobs=6

export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

unalias cat > /dev/null 2>&1
unalias zip > /dev/null 2>&1

cc_ver="$(${CROSS_COMPILE}gcc --version|head -n1|cut -d'(' -f2|tr -d ')'|awk '{$5=""; print $0}'|sed -e 's/[[:space:]]*$//')"
MAKEFLAGS=("KBUILD_COMPILER_STRING=${cc_ver}")

# helpers
source helpers.sh
