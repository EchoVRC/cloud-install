#!/bin/bash

pacman -Rdd iptables --noconfirm
pacman -S kubeadm haproxy bash-completion docker kubernetes-control-plane iptables-nft --noconfirm

curl 'https://raw.githubusercontent.com/lamfo-dev/cloud-install/main/configs/haproxy.cfg' -o /etc/haproxy/haproxy.cfg
curl 'https://raw.githubusercontent.com/lamfo-dev/cloud-install/main/configs/nftables.conf' -o /etc/nftables.conf

ip=$(ip -4 addr show cluster.service | grep -oP "(?<=inet ).*(?=/)")
if [[ ! -z "$ip" ]]; then
  mkdir /etc/systemd/system/kubelet.service.d
  cp /lib/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  sed -i 's!\(ExecStart=/usr/bin/kubelet\)!\1 --node-ip='$ip'!g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi

systemctl enable kubelet boltd
systemctl enable --now docker haproxy nftables
