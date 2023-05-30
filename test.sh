#! /bin/sh
#https://www.kernel.org/doc/html/latest/admin-guide/initrd.html

if [ -z "$KERNEL" ]
then
  KERNEL=$(uname -r)
fi

qemu-system-x86_64 -machine accel=kvm -m 2G -serial stdio -net nic,model=e1000 -append "root=/dev/ram0 rw console=tty1" -kernel $(ls /boot/vmlinuz-$KERNEL) -initrd $1
