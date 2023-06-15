#!/bin/bash

# Bit Sizes
# 1 = 2MB
# 2 = 4MB
# 3 = 8MB
# 4 = 16MB
# 5 = 32MB
# 6 = 64MB
# 7 = 128MB
# 8 = 256MB
# 9 = 512MB
# 10 = 1GB
# 11 = 2GB
# 12 = 4GB
# 13 = 8GB
# 14 = 16GB
# 15 = 32GB

## Paramètres de/des BAR
valeur_bar_0=""
valeur_bar_1="14"
valeur_bar_2=""
valeur_bar_3=""


grub_extras=`cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX_DEFAULT"`
pci_ids=`echo $grub_extras | grep -o 'vfio-pci[^ ]*' | cut -d= -f2- | sed 's/"//' | sed 's/,/ /g'`
for pci_id in $pci_ids ; do
  device=`lspci -d $pci_id`
  device_number=`echo $pci_id | sed 's/.*://'`
  device_id=`echo $device | awk '{ print $1}'`
##  echo "GRUB ID : "$pci_id
##  echo "PCI ID : "$device_id
  check_vga=` lspci -s $device_id | grep "VGA compatible controller"`
  if [[ "$check_vga" != "" ]]; then
    my_vga=$device_id
  fi
done

if [[ "$my_vga" == "" ]]; then
  echo "Aucune carte graphique détectée"
  exit 0
fi

echo "La carte graphique: "$my_vga
bar_0=` lspci -vvvs $my_vga | grep "BAR 0:" | awk '{ print $5 }' | sed 's/,//'`
bar_1=` lspci -vvvs $my_vga | grep "BAR 1:" | awk '{ print $5 }' | sed 's/,//'`
bar_2=` lspci -vvvs $my_vga | grep "BAR 2:" | awk '{ print $5 }' | sed 's/,//'`
bar_3=` lspci -vvvs $my_vga | grep "BAR 3:" | awk '{ print $5 }' | sed 's/,//'`
if [[ "$bar_0" != "" ]] || [[ "$bar_1" != "" ]] || [[ "$bar_2" != "" ]] || [[ "$bar_3" != "" ]]; then
  echo "Resizable BAR possible."
  echo "... unbind de la carte graphique"
  echo -n "0000:$my_vga" > /sys/bus/pci/drivers/vfio-pci/unbind
  if [[ "$bar_0" != "" ]] && [[ "$valeur_bar_0" != "" ]]; then
    echo "BAR 0 actuel: "$bar_0
    echo "BAR 0 désiré: "$valeur_bar_0
    echo "... modification de la valeur"
    echo "$valeur_bar_0" > "/sys/bus/pci/devices/0000:$my_vga/resource0_resize"
    nouveau_bar_0=` lspci -vvvs $my_vga | grep "BAR 0:" | awk '{ print $5 }' | sed 's/,//'`
    echo "BAR 0 nouveau: "$nouveau_bar_0
  fi
  if [[ "$bar_1" != "" ]] && [[ "$valeur_bar_1" != "" ]]; then
    echo "BAR 1 actuel: "$bar_1
    echo "BAR 1 désiré: "$valeur_bar_1
    echo "... modification de la valeur"
    echo "$valeur_bar_1" > "/sys/bus/pci/devices/0000:$my_vga/resource1_resize"
    nouveau_bar_1=` lspci -vvvs $my_vga | grep "BAR 1:" | awk '{ print $5 }' | sed 's/,//'`
    echo "BAR 1 nouveau: "$nouveau_bar_1
  fi
  if [[ "$bar_2" != "" ]] && [[ "$valeur_bar_2" != "" ]]; then
    echo "BAR 2 actuel: "$bar_2
    echo "BAR 2 désiré: "$valeur_bar_2
    echo "... modification de la valeur"
    echo "$valeur_bar_2" > "/sys/bus/pci/devices/0000:$my_vga/resource2_resize"
    nouveau_bar_2=` lspci -vvvs $my_vga | grep "BAR 2:" | awk '{ print $5 }' | sed 's/,//'`
    echo "BAR 2 nouveau: "$nouveau_bar_2
  fi
  if [[ "$bar_3" != "" ]] && [[ "$valeur_bar_3" != "" ]]; then
    echo "BAR 3 actuel: "$bar_3
    echo "BAR 3 désiré: "$valeur_bar_3
    echo "... modification de la valeur"
    echo "$valeur_bar_3" > "/sys/bus/pci/devices/0000:$my_vga/resource3_resize"
    nouveau_bar_3=` lspci -vvvs $my_vga | grep "BAR 3:" | awk '{ print $5 }' | sed 's/,//'`
    echo "BAR 3 nouveau: "$nouveau_bar_3
  fi
else
  echo "La carte graphique ne possède pas de Resizable BAR"
  exit 0
fi

echo "... bind de la carte graphique"
echo -n "0000:$my_vga" > /sys/bus/pci/drivers/vfio-pci/bind
