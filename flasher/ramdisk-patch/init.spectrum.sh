#!/system/bin/sh
# SPECTRUM KERNEL MANAGER
# Profile initialization script by nathanchance

# If there is not a persist value, we need to set one
if [ ! -f /data/property/persist.spectrum.profile ]; then
	setprop persist.spectrum.profile 0
fi

# Ensure settings take effect
setprop persist.spectrum.profile $(getprop persist.spectrum.profile)

# Destroy our /system scripts if another kernel has been installed
if ! grep -qi velocity /proc/version; then
	mount -o remount,rw /system_root || exit 1
	rm -f /system_root/init.spectrum.sh /system_root/init.spectrum.rc /system_root/init.velocity.rc
	sed -i '/init.velocity.rc/d' /system_root/init.rc
	sed -i '/init.spectrum.rc/d' /system_root/init.rc
fi
