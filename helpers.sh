mkzip() {
    echo '  ZIP     velocity_kernel.zip'
    rm velocity_kernel.zip
    cp arch/arm64/boot/Image.gz flasher/
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3.dtb flasher/base.dtb
    cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-treble.dtb flasher/treble.dtb
    cd flasher
    zip -r9 ../velocity_kernel.zip .
    cd ..
}

cleanbuild() {
    make clean && make -j$jobs && mkzip
}

incbuild() {
    make -j$jobs && mkzip
}

test() {
    adb shell ls '/init.recovery*' > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        adb reboot recovery && \
        sleep 20
    fi

    adb reboot recovery && \
    sleep 35 && \
    adb push velocity_kernel.zip /tmp && \
    adb shell twrp install /tmp/velocity_kernel.zip && \
    adb shell reboot
}

inc() {
    incbuild && test
}
