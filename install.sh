#!/bin/bash

### CHECK
ls /dev/loop0 > /dev/null || ( echo 'Ты псих?' && exit 1 )

### CLEAR
swapoff -a
umount /mnt/boot
umount /mnt

### NETWORK
echo 'nameserver 1.1.1.1' > /etc/resolv.conf
dev=$(ip -br a show | grep UP | awk '{print $1}')
while [[ ! `ping -c 1 1.1`  ]]; do
  read -p 'IP: ' ip
  read -p 'GW: ' gw
  ip add add $ip dev $dev
  ip ro add 0.0.0.0/0 via $gw
done


### DISK
disk=$(fdisk -l | grep '^Disk /dev/' | sort -hk 3 | head -n1 | awk '{print $2}' | tr -d ':')
echo "Выполняю установку на диск $disk"

dd if=/dev/zero of=${disk} bs=8M count=256 > /dev/null 

parted $disk -s  mklabel msdos
parted $disk -s mkpart primary 1M 512M
parted $disk -s mkpart primary 512M 100%
parted $disk set 1 boot on

mkfs.ext2 ${disk}1 -F
mkfs.ext4 ${disk}2 -F

mount ${disk}2 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot

dd if=/dev/zero of=/mnt/swap bs=8M count=64 > /dev/null 
chmod 0600 /mnt/swap
mkswap /mnt/swap 
swapon /mnt/swap 

pacstrap /mnt base base-devel linux linux-firmware grub sudo git make curl wget htop vim net-tools ethtool openssh wireguard-tools

genfstab -U /mnt > /mnt/etc/fstab
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
echo -e 'en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8' > /etc/locale.gen

arch-chroot /mnt /bin/bash <<"EOT"
  disk=$(fdisk -l | grep '^Disk /dev/' | sort -hk 3 | head -n1 | awk '{print $2}' | tr -d ':')
  grub-install ${disk}
  grub-mkconfig -o /boot/grub/grub.cfg
  
  timedatectl set-timezone Europe/Moscow
  locale-gen
  
  curl 'https://raw.githubusercontent.com/lamfo-dev/ssh/main/fastadd.sh' | bash --
  systemctl enable sshd
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  
  useradd -c lamfo -g users -G wheel lamfo
  
  pwd
EOT


