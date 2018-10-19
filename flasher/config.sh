#!/sbin/sh

# if this is changed, it also needs to be set in boot-patcher.sh, update-binary, and patch.d-env
tmp=/tmp/vflash
device_names="tissot tissot_sprout tiffany"
boot_block=
ramdisk_compression=
# if you enable this, you will need to add /data mounting to the update-binary script
# boot_backup=/data/local/boot-backup.img

bin=$tmp/tools
ramdisk=$tmp/ramdisk
ramdisk_patch=$ramdisk-patch
split_img=$tmp/split-img

arch=arm64
bin=$bin/$arch
