#!/bin/bash


echo ""
echo "### CHECKING DEPENDENCIES"
dependencies="qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf"
for dependency in $dependencies; do
  check_apt=` apt list --installed 2>/dev/null | grep $dependency`
  if [[ "$dependency" != "" ]]; then
    echo "APT : $dependency installed"
  else
    echo "APT : $dependency not installed"
    exit 0
  fi
done
echo ""
echo "### VERSIONS"
virsh version
echo "### HARDWARE"
grub_extras=`cat /etc/default/grub | grep "^GRUB_CMDLINE_LINUX_DEFAULT"`
##echo ""
cpu_brand=` cat /proc/cpuinfo | grep 'vendor' | uniq`
if [[ "$cpu_brand" =~ "AMD" ]]; then
  echo "CPU : AMD detected"
  check_iommu=` echo $grub_extras | grep "amd_iommu=on"`
  check_iommu2=` echo $grub_extras | grep "iommu=pt"`
  if [[ "$check_iommu" != "" ]] && [[ "$check_iommu2" != "" ]]; then
    echo "GRUB : Ready for AMD CPU"
  else
    echo "GRUB : Not ready for AMD CPU"
    exit 0
  fi
  amd_svm=` cat /proc/cpuinfo | grep svm`
  if [[ "$amd_svm" != "" ]]; then
    echo "BIOS SVM : Ok"
  else
    echo "BIOS SVM : No"
    exit 0
  fi
  echo "AMD-VI :"
  dmesg | grep AMD-Vi
elif [[ "$cpu_brand" =~ "Intel" ]]; then
  echo "CPU : Intel detected"
  check_iommu=` echo $grub_extras | grep "intel_iommu=on"`
  if [[ "$check_iommu" != "" ]]; then
    echo "GRUB : Ready for Intel CPU"
  else
    echo "GRUB : Not ready for Intel CPU"
    exit 0
  fi
  intel_vmx=` cat /proc/cpuinfo | grep vmx`
  if [[ "$intel_vmx" != "" ]]; then
    echo "BIOS VMX : Ok"
  else
    echo "BIOS VMX : No"
    exit 0
  fi
else
  echo "Unknown CPU"
  exit 0
fi
echo ""
echo "### GRUB OPTIONAL :"
if [[ $(echo $grub_extras | grep "kvm.ignore_msrs=1") != "" ]]; then echo "- IGNORE_MSRS : YES"; else echo "- IGNORE_MSRS : NO"; fi
if [[ $(echo $grub_extras | grep "nofb") != "" ]]; then echo "- NOFB : YES"; else echo "- NOFB : NO"; fi
if [[ $(echo $grub_extras | grep "simplefb:off") != "" ]]; then echo "- SIMPLEFB : YES"; else echo "- SIMPLEFB : NO"; fi
if [[ $(echo $grub_extras | grep "efifb:off") != "" ]]; then echo "- EFIFB : YES"; else echo "- EFIFB : NO"; fi
if [[ $(echo $grub_extras | grep "vesafb:off") != "" ]]; then echo "- VESAFB : YES"; else echo "- VESAFB : NO"; fi
if [[ $(echo $grub_extras | grep "vesa:off") != "" ]]; then echo "- VESA : YES"; else echo "- VESA : NO"; fi
pci_ids=`echo $grub_extras | grep -o 'vfio-pci[^ ]*' | cut -d= -f2- | sed 's/"//' | sed 's/,/ /g'`
echo ""
echo "###"
echo "### ISOLATION / USAGE"
echo "###"
isolation_count=` echo $pci_ids | wc -w`
if [[ "$isolation_count" == "0" ]]; then
  echo ""
  echo "GRUB : No isolation detected"
  echo ""
  exit 0
else
  echo ""
  echo "GRUB : $isolation_count devices isolated"
  echo ""
fi
for pci_id in $pci_ids ; do
  device=`lspci -d $pci_id`
  device_number=`echo $pci_id | sed 's/.*://'`
  device_id=`echo $device | awk '{ print $1}'`
  id_01=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $1 }'`
  id_02=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $2 }'`
  id_03=`echo $device_id | sed -e 's/[^0-9]/ /g' | awk '{ print $3 }'`
  echo "HW ID : "$pci_id
  echo "PCI ID : "$device_id
  virsh_pci_id=`echo "pci_0000_"$id_01"_"$id_02"_"$id_03""`
  virsh_device=` lspci -s $device_id | cut -f 2- -d ' ' | sed 's/ (rev.*//'`
  echo "TYPE : "$virsh_device
  driver_used=` lspci -nnvs $device_id | grep "Kernel driver in use" | awk '{ print $NF }'`
  echo "KERNEL DRIVER :" $driver_used
  vm_names=` virsh list --name`
  for vm_name in $vm_names; do
    vm_xml=` virsh dumpxml $vm_name > $HOME/vm.xml`
##    cat $HOME/vm.xml
    vm_check=` cat $HOME/vm.xml | grep "<address domain='0x0000' bus='0x$id_01' slot='0x$id_02' function='0x$id_03'/>"`
    ## maybe virsh nodedev-dumpxml pci_0000_01_00_0



##    rm $HOME/vm.xml
    if [[ "$vm_check" != "" ]]; then
      echo "VM \"$vm_name\": Device detected"
    else
      echo "VM \"$vm_name\": Device missing"
    fi
  done
  echo "DMESG :"
  dmesg | grep $device_id
  echo ""
done
echo "### KERNEL ERRORS :"
cat /var/log/kern.log | grep error
echo ""
echo "### DMESG ERRORS :"
dmesg | grep error

