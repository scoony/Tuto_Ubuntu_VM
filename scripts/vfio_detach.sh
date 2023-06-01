#!/bin/bash

grub_extras=`cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX_DEFAULT"`
pci_ids=`echo $grub_extras | grep -o 'vfio-pci[^ ]*' | cut -d= -f2- | sed 's/"//' | sed 's/,/ /g'`
for pci_id in $pci_ids ; do
  device=`lspci -d $pci_id`
  device_number=`echo $pci_id | sed 's/.*://'`
  device_id=`echo $device | awk '{ print $1}'`
  id_01=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $1 }'`
  id_02=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $2 }'`
  id_03=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $3 }'`
  echo "GRUB ID : "$pci_id
  echo "PCI ID : "$device_id
  virsh_pci_id=`echo "pci_0000_"$id_01"_"$id_02"_"$id_03""`
  echo "VIRSH ID : "$virsh_pci_id
  virsh nodedev-detach "$virsh_pci_id"
done
