#! /bin/bash

kexec -l /boot/vmlinuz-$(uname -r) --initrd=/boot/initrd.img-$(uname -r) --command-line="$(cat /proc/cmdline)"
kexec -e
