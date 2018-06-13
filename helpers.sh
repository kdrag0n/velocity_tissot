_RELEASE=0

mkzip() {
    echo '  ZIP     velocity_kernel.zip'
    rm -f velocity_kernel.zip
    [ $_RELEASE -eq 0 ] && cp arch/arm64/boot/Image flasher/Image-custom
    [ $_RELEASE -eq 0 ] && rm -f flasher/.rel
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3.dtb flasher/base.dtb
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-treble.dtb flasher/treble.dtb
    cd flasher
    zip -r9 ../velocity_kernel.zip . > /dev/null
    cd ..
}

rel() {
    _RELEASE=1

    # Swap out version files
    [ ! -f .relversion ] && echo 0 > .relversion
    mv .version .devversion && \
    mv .relversion .version

    # Compile for custom
    make oldconfig && \
    make "${MAKEFLAGS[@]}" -j$jobs && \
    cp arch/arm64/boot/Image flasher/Image-custom && \

    # Reset version
    echo $(($(cat .version) - 1)) >| .version && \

    # Disable pronto for stock
    cp .config .occonfig && \
    sed -i 's/CONFIG_PRONTO_WLAN=y/# CONFIG_PRONTO_WLAN is not set/' .config && \
    make oldconfig && \

    # Compile for stock
    make "${MAKEFLAGS[@]}" -j$jobs && \

    # Create patch delta
    echo '  BSDIFF  flasher/stock.delta' && \
    # Custom bsdiff that matches revised format of flasher patcher
    ./bsdiff flasher/Image-custom arch/arm64/boot/Image flasher/stock.delta

    # Revert version and config files
    mv .occonfig .config && \
    mv .version .relversion && \
    mv .devversion .version

    # Pack zip
    touch flasher/.rel && \
    mkzip && \
    mkdir -p releases

    # Rename to release format
    fn="releases/velocity_kernel-tissot-r$(cat .relversion)-$(date +%Y%m%d).zip" && \
    echo "  REL     $fn" && \
    mv velocity_kernel.zip "$fn"

    # Fix config for next build
    make oldconfig

    _RELEASE=0
}

zerover() {
    echo 0 >| .version
}

cleanbuild() {
    make "${MAKEFLAGS[@]}" clean && make -j$jobs && mkzip
}

incbuild() {
    make "${MAKEFLAGS[@]}" -j$jobs && mkzip
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
