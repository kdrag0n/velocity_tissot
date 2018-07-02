#!/system/bin/sh
# VELOCITY KERNEL
# Early initialization script

echo RUN >> /dev/abcdef
# Wi-Fi module
if [ -f /system/vendor/lib/modules/pronto/pronto_wlan.ko ]; then # stock
    echo STOCK >> /dev/abcdef
    cp /pronto_wlan.ko /dev/.pronto_wlan.ko >> /dev/abcdef 2>&1
    echo CP >> /dev/abcdef
    chcon u:object_r:vendor_file:s0 /dev/.pronto_wlan.ko >> /dev/abcdef 2>&1
    echo CON >> /dev/abcdef
    mount --bind /dev/.pronto_wlan.ko /system/vendor/lib/modules/pronto/pronto_wlan.ko >> /dev/abcdef 2>&1
    echo BIND >> /dev/abcdef
else # custom
    echo CUSTOM >> /dev/abcdef
    insmod /pronto_wlan.ko
    echo INS >> /dev/abcdef >> /dev/abcdef 2>&1
fi
echo DONE >> /dev/abcdef
