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

mkdir  -p "$DESTDIR/usr/lib"
mkdir  -p "$DESTDIR/usr/lib64"
mkdir  -p "$DESTDIR/usr/bin"
mkdir  -p "$DESTDIR/usr/sbin"

ln -s usr/lib "$DESTDIR/lib"
ln -s usr/lib64 "$DESTDIR/lib64"
ln -s usr/bin "$DESTDIR/bin"
ln -s usr/sbin "$DESTDIR/sbin"

cp -v /bin/busybox "$DESTDIR/bin/"
"$DESTDIR/bin/busybox" --install -s "$DESTDIR/bin/"
for n in $(find "$DESTDIR/bin/" -type l); do rm $n; ln -s ./busybox $n; done


. /usr/share/initramfs-tools/hook-functions

copy_exec /usr/sbin/gdisk
copy_exec /usr/sbin/e2fsck
copy_exec /usr/sbin/resize2fs
copy_exec /usr/bin/lsblk

auto_add_modules net ata ide scsi block

echo "#! /bin/sh

mount -t sysfs -o nodev,noexec,nosuid sysfs /sys
mount -t proc -o nodev,noexec,nosuid proc /proc

mount -t devtmpfs -o nosuid,mode=0755 udev /dev

# Prepare the /dev directory
[ ! -h /dev/fd ] && ln -s /proc/self/fd /dev/fd
[ ! -h /dev/stdin ] && ln -s /proc/self/fd/0 /dev/stdin
[ ! -h /dev/stdout ] && ln -s /proc/self/fd/1 /dev/stdout
[ ! -h /dev/stderr ] && ln -s /proc/self/fd/2 /dev/stderr

mkdir /dev/pts
mount -t devpts -o noexec,nosuid,gid=5,mode=0620 devpts /dev/pts || true

modprobe ata_piix
modprobe sd_mod

/bin/ash
poweroff -f
" > "$DESTDIR/init"
chmod +x "$DESTDIR/init"

depmod -b "$DESTDIR"

echo "Wrapping up to cpio.gz file"
cd "$DESTDIR"
find . | cpio --quiet -H newc -o | gzip -9  -n > ../"$(basename "$DESTDIR").cpio.gz"
