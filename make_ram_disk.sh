#! /bin/bash


export DESTDIR=$1
export CONFDIR=$(readlink -f $(dirname $0))
export version=$(uname -r)
export MODULESDIR=/lib/modules/$version
export verbose="n"


if [ -z "$DESTDIR" ]
then
  echo "No DESTDIR folder given."
  exit 1
fi

mkdir -p $DESTDIR
mkdir -p "$DESTDIR/proc"
mkdir -p "$DESTDIR/sys"
mkdir -p "$DESTDIR/dev"
mkdir -p "$DESTDIR/conf"
mkdir -p "$DESTDIR/etc"

mkdir  -p "$DESTDIR/usr/lib"
mkdir  -p "$DESTDIR/usr/lib64"
mkdir  -p "$DESTDIR/usr/bin"
mkdir  -p "$DESTDIR/usr/sbin"

ln -s usr/lib "$DESTDIR/lib"
ln -s usr/lib64 "$DESTDIR/lib64"
ln -s usr/bin "$DESTDIR/bin"
ln -s usr/sbin "$DESTDIR/sbin"
ln -s /proc/mounts "$DESTDIR/etc/mtab"

cp -v /bin/busybox "$DESTDIR/bin/"
"$DESTDIR/bin/busybox" --install -s "$DESTDIR/bin/"
for n in $(find "$DESTDIR/bin/" -type l); do rm $n; ln -s ./busybox $n; done


. /usr/share/initramfs-tools/hook-functions

copy_exec /usr/sbin/gdisk
copy_exec /usr/sbin/e2fsck
copy_exec /usr/sbin/resize2fs
copy_exec /usr/bin/lsblk

auto_add_modules net ata ide scsi block
add_loaded_modules

force_load ata_piix
force_load sd_mod

cp "$CONFDIR/init" "$DESTDIR"
chmod +x "$DESTDIR/init"

depmod -b "$DESTDIR"

echo "Wrapping up to cpio.gz file"
cd "$DESTDIR"
find . | cpio --quiet -H newc -o | gzip -9  -n > ../"$(basename "$DESTDIR").cpio.gz"
