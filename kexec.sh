#! /bin/bash

kexec -l /boot/vmlinuz-5.10.0-23-cloud-amd64 --initrd=$1 --command-line="root=/dev/ram0 rw console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200"
kexec -e
