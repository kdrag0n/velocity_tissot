#!/system/bin/sh
# VELOCITY KERNEL
# Early initialization script

echo START >> /dev/abcdef
# Wi-Fi module
if [ -f /system/vendor/lib/modules/pronto/pronto_wlan.ko ]; then # stock
    cp /pronto_wlan.ko /dev/.pronto_wlan.ko
    chcon u:object_r:vendor_file:s0 /dev/.pronto_wlan.ko
    mount --bind /dev/.pronto_wlan.ko /system/vendor/lib/modules/pronto/pronto_wlan.ko
else # custom
    insmod /pronto_wlan.ko
fi
echo DONE >> /dev/abcdef
