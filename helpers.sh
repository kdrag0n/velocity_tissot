_RELEASE=0

mkzip() {
    [ $_RELEASE -eq 0 ] && rm -f flasher/.rel
    [ $_RELEASE -eq 1 ] && touch flasher/.rel
    cp arch/arm64/boot/Image.gz flasher/
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3.dtb flasher/base.dtb
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-treble.dtb flasher/treble.dtb
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-tiffany.dtb flasher/tiffany.dtb
    echo -n $(date "+%a %b '%y at %H:%M") >| flasher/.build
    cat .version|tr -d '\n' >| flasher/.ver
    cd flasher

    fn="velocity_kernel.zip"
    [ "x$1" != "x" ] && fn="$1"
    rm -f "../$fn"
    echo "  ZIP     $fn"
    zip -r9 "../$fn" . -x .gitignore > /dev/null
    cd ..
}

rel() {
    _RELEASE=1

    # Swap out version files
    [ ! -f .relversion ] && echo 0 > .relversion
    mv .version .devversion && \
    mv .relversion .version

    # Compile kernel
    make oldconfig # solve a weird "cached" config
    make "${MAKEFLAGS[@]}" -j$jobs

    # Pack zip
    mkdir -p releases
    mkzip "releases/velocity_kernel-tissot-r$(cat .version)-$(date +%Y%m%d).zip"

    # Revert version
    mv .version .relversion && \
    mv .devversion .version

    _RELEASE=0
}

zerover() {
    echo 0 >| .version
}

real_make="$(command which make)"

make() {
    "$real_make" "${MAKEFLAGS[@]}" "$@"
}

cleanbuild() {
    make clean && make -j$jobs && mkzip
}

incbuild() {
    make -j$jobs && mkzip
}

dbuild() {
    make -j$jobs $@ && dzip
}

dzip() {
    mkdir -p betas
    mkzip "betas/velocity_kernel-tissot-b$(cat .version)-$(date +%Y%m%d).zip"
}

test() {
    adb wait-for-any && \
    adb shell ls '/init.recovery*' > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        adb reboot recovery
    fi

    fn="velocity_kernel.zip"
    [ "x$1" != "x" ] && fn="$1"
    adb wait-for-usb-recovery && \
    adb push $fn /tmp/kernel.zip && \
    adb shell "twrp install /tmp/kernel.zip && reboot"
}

inc() {
    incbuild && test
}

dc() {
    diff arch/arm64/configs/velocity_defconfig .config
}

cpc() {
    cp .config arch/arm64/configs/velocity_defconfig
}

mc() {
    make velocity_defconfig
}

cf() {
    make nconfig
}
