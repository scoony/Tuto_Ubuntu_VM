#!/bin/bash

echo -n "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "15" > /sys/bus/pci/devices/0000\:03\:00.0/resource0_resize
echo "3" > /sys/bus/pci/devices/0000\:03\:00.0/resource2_resize
echo -n "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
