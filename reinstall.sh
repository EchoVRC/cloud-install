#!/bin/bash

[[ "$(hostname)" == "nts02.lamfo.ru" ]] && echo 'Бум' && exit 2

wget 'ftp://ftp.nluug.nl/pub/os/Linux/distr/archlinux/iso/latest/archlinux-bootstrap-*-x86_64.tar.gz'

mkdir /mnt_old

mount -t tmpfs none /mnt_old
cd /mnt_old
pwd
tar xvf ~/archlinux-bootstrap-*-x86_64.tar.gz --strip-components=1

cp -r /root/.ssh root
cp /etc/resolv.conf etc
cp /etc/hostname etc
cp -r /etc/pacman* etc


mount --make-rprivate /
for i in run proc sys dev; do mount --move /$i /mnt_old/$i; done
mkdir /mnt_old
mkdir mnt_old
pivot_root . mnt_old
exec chroot .  <<"EOT"

  pacman-key --init
  pacman-key --populate archlinux
  pacman-key --refresh-keys --keyserver keys.gnupg.net

  sed -i 's/CheckSpace//g' /etc/pacman.conf
  pacman -Sy psmisc openssh arch-install-scripts vim base base-devel --noconfirm

  cp /mnt_old/etc/ssh/* /etc/ssh
  #killall -HUP sshd

  umount /mnt_old

  curl 'https://raw.githubusercontent.com/lamfo-dev/cloud-install/main/install.sh' | bash --
EOT
