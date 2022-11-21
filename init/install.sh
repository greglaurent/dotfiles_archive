#!/bin/bash

DRIVE=$1
P1="${DRIVE}p1"
P2="${DRIVE}p2"
P3="${DRIVE}p3"

SWAP_GiB=$(($2 + 1)

SWAP_STR="${SWAP_GiB}GiB"

parted "${DRIVE}" -- mklabel GPT
parted "${DRIVE}" -- mkpart ESP fat32 1MiB 1GiB
parted "${DRIVE}" -- set 1 boot on
mkfs.vfat "${P1}"

parted "${DRIVE}" -- mkpart swap linux-swap 1GiB "${SWAP_STR}"
mkswap -L SWAP "${P2}"
swapon "${P2}"

parted "${DRIVE}" -- mkpart nixos "${SWAP_STR}" 100%
mkfs.btrfs -L nixos "${P3}"

mount "${P3}" /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/etc
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
umount /mnt

mount -t tmpfs -o mode=755 none /mnt
mkdir -p /mnt/{boot,nix,etc,var/log,root,home}
mount "${P1}" /mnt/boot
mount -o subvol=nix,compress-force=zstd,noatime "${P3}" /mnt/nix
mount -o subvol=etc,compress-force=zstd,noatime "${P3}" /mnt/etc
mount -o subvol=log,compress-force=zstd,noatime "${P3}" /mnt/var/log
mount -o subvol=root,compress-force=zstd,noatime "${P3}" /mnt/root
mount -o subvol=home,compress-force=zstd,noatime "${P3}" /mnt/home

nixos-generate-config --root /mnt

cp -f ./configuration.nix.bak /mnt/etc/nixos/configuration.nix
nixos-install
