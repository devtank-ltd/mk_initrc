#! /bin/sh
#https://www.kernel.org/doc/html/latest/admin-guide/initrd.html

qemu-system-x86_64 -machine accel=kvm -m 2G -hda disk.img -serial stdio -append "root=/dev/ram0 rw console=ttyS0" -kernel $(ls /boot/vmlinuz-$(uname -r)) -initrd $1
