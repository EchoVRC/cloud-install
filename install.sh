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

#dd if=/dev/zero of=/mnt/swap bs=8M count=64 > /dev/null 
#chmod 0600 /mnt/swap
#mkswap /mnt/swap 
#swapon /mnt/swap 

sed -i 's/#ParallelDownloads = [0-9]*/ParallelDownloads = 5/g' /etc/pacman.conf

pacstrap /mnt base base-devel linux linux-firmware grub sudo git make curl wget htop vim net-tools ethtool openssh wireguard-tools tcpdump nload 

sed -i 's/#ParallelDownloads = [0-9]*/ParallelDownloads = 5/g' /mnt/etc/pacman.conf

genfstab -U /mnt > /mnt/etc/fstab
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
echo -e 'en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8' > /mnt/etc/locale.gen


interface=$(ip route get 1.1.1.1 | head -n 1 | sed 's/.* dev \(.*\) src .*/\1/g')
ip=$(ip -4 -o addr show dev $interface | sed 's/.*inet \([^ ]*\) .*/\1/g')
gateway=$(ip route get 1.1.1.1 | head -n 1 | sed 's/.* via \(.*\) dev.*/\1/g')

echo -en "[Match]
Name=$interface

[Network]
Address=$ip
Gateway=$gateway" > /mnt/etc/systemd/network/$interface.network
echo 'nameserver 1.1.1.1' > /mnt/etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /mnt/etc/resolv.conf

arch-chroot /mnt /bin/bash <<"EOT"
  disk=$(fdisk -l | grep '^Disk /dev/' | sort -hk 3 | head -n1 | awk '{print $2}' | tr -d ':')
  grub-install ${disk}
  grub-mkconfig -o /boot/grub/grub.cfg
  sed -i /boot/grub/grub.cfg 's/set timeout=[0-9]*/set timeout=0/g'
  
  timedatectl set-timezone Europe/Moscow
  timedatectl set-ntp on
  
  locale-gen
  
  curl 'https://raw.githubusercontent.com/lamfo-dev/ssh/main/fastadd.sh' | bash -- 
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  
  wget https://raw.githubusercontent.com/lamfo-dev/cloud-install/main/profile -O /root/.bashrc
  ln -s /root/.bashrc .bash_profile
  chmod +x .bash_profile .bashrc
  
  wget https://raw.githubusercontent.com/lamfo-dev/cloud-install/main/10-netowrk.conf -O /etc/sysctl.d/10-netowrk.conf 
  
  systemctl enable systemd-timesyncd systemd-networkd sshd
  
  useradd -c lamfo -g users -G wheel lamfo
  
  pwd
EOT


