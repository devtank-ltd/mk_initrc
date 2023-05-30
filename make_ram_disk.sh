#! /bin/bash

set -e

if [ -z "$KERNEL" ]
then
  KERNEL=$(uname -r)
fi

export DESTDIR=$1
export CONFDIR=$(readlink -f $(dirname $0))
export version=$KERNEL
export MODULESDIR=/lib/modules/$version
export verbose="n"


if [ -z "$DESTDIR" ]
then
  echo "No DESTDIR folder given."
  exit 1
fi

rm -rf "$DESTDIR"

mkdir -p "$DESTDIR"
cp -a "$CONFDIR"/base/* "$DESTDIR/"
grep root /etc/shadow > "$DESTDIR/"etc/shadow
chown root:shadow "$DESTDIR/"etc/shadow
chmod 640 "$DESTDIR/"etc/shadow

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

# Required to avoid grep error
touch modules

. /usr/share/initramfs-tools/hook-functions

copy_exec /bin/busybox

"$DESTDIR/bin/busybox" --install -s "$DESTDIR/bin/"
for n in $(find "$DESTDIR/bin/" -type l); do rm $n; ln -s ./busybox $n; done

exces=(/usr/sbin/gdisk /usr/sbin/e2fsck /usr/sbin/resize2fs /usr/bin/lsblk /usr/sbin/dropbear)
for exe in ${exces[@]}
do
  if [ ! -e $exe ]
  then
    echo "$exe not found"
    exit 1
  fi
  copy_exec $exe
done

auto_add_modules net ata ide scsi block
add_loaded_modules

force_load ata_piix
force_load sd_mod

# Take all the currently loaded modules into initrc
modules=$(echo $(lsmod | awk 'NR>1 {print $1}'))
for mod in $modules
do
  force_load $mod
done

depmod -b "$DESTDIR" $KERNEL

echo "Wrapping up to cpio.gz file"
cd "$DESTDIR"
find . | cpio --quiet -H newc -o | gzip -9  -n > ../"$(basename "$DESTDIR").cpio.gz"
