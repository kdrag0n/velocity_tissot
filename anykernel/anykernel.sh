# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

cat <<EOF
__     __   _            _ _
\ \   / /__| | ___   ___(_) |_ _   _
 \ \ / / _ \ |/ _ \ / __| | __| | | |
  \ V /  __/ | (_) | (__| | |_| |_| |
   \_/ \___|_|\___/ \___|_|\__|\__, |
                               |___/

-------------------------------------
EOF
## AnyKernel setup
# begin properties
properties() {
kernel.string=Velocity Kernel by kdragon and tytydraco
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=tissot
device.name2=Mi A1
device.name3=tissot_sprout
} # end properties

# shell variables
block=/dev/block/platform/soc/7824900.sdhci/by-name/boot;
ramdisk=/tmp/anykernel/ramdisk
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

if [ -d $ramdisk/.subackup -o -d $ramdisk/.backup ]; then
  patch_cmdline "skip_override" "skip_override";
else
  patch_cmdline "skip_override" "";
fi;

# begin ramdisk changes

cp /tmp/anykernel/init.spectrum.rc $ramdisk/
cp /tmp/anykernel/init.spectrum.sh $ramdisk/
chmod 644 $ramdisk/init.spectrum.rc
chmod 644 $ramdisk/init.spectrum.sh
insert_line init.rc "import /init.spectrum.rc" after "import /init.usb.rc" "import /init.spectrum.rc"

# end ramdisk changes

write_boot;

## end install

