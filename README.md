Introduction
============

What is this crazy thing?

Well you know when you have a machine you only have remote access to, you have a console, but grub isn't being used.
BUT you want to repartition, well this is my solution.

It builds a custom init RAM disk, with some tools in it, which you can then boot to with kexec.

You could get DHCP networking and SSH working in it, but I didn't take it that far, as I had a console.

This assumes a Debian based system, and that kexec, qemu, dropbear, util-linux, e2fsprogs, gdisk and busybox.


Files
=====

* make_ram_disk.sh  -  Create a ramdisk in the folder name given.
* test.sh - Boots given ramdisk with qmeu.
* kexec.sh - Reboot system with given ramdisk.

All will use the current kernel, unless the environment variable KERNEL is set.


Example
=======

    e2fsck -f /dev/vda1 # You have to do this because of the kexec
    resize2fs /dev/vda1 30G # Resize to small that new partition size, in this case 30G for 32G
    gdisk /dev/vda  # Delete p1 and recreate as 32G, then create fresh partion in empty space
    resize2fs /dev/vda1 # Resize filesystem to what is aligned 32G
    reboot -f # Hold on to your butts!
