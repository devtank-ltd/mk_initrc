#! /bin/bash

if [ -z "$KERNEL" ]
then
  KERNEL=$(uname -r)
fi

kexec -l /boot/vmlinuz-$KERNEL --initrd=$1 --command-line="root=/dev/ram0 rw console=tty1"
kexec -e
