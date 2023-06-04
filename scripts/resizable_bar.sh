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

## J'ai mis 32/8

echo -n "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "15" > /sys/bus/pci/devices/0000\:03\:00.0/resource0_resize
echo "3" > /sys/bus/pci/devices/0000\:03\:00.0/resource2_resize
echo -n "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
