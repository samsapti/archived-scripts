#!/bin/sh

### MAKE SURE THE FOLLOWING TWO LINES ARE IN YOUR /etc/mkinitcpio.conf:
### #MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)
### MODULES=()

if [ "$(lsb_release -si)" = "Arch" ] || [ "$(lsb_release -si)" = "Artix" ]; then
    echo "This script must be run on either Arch Linux or Artix Linux. Quitting..."
fi

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root. Quitting..."
    exit 1
fi

if [ "$1" = "on" ]; then
    if grep "#MODULES=()" /etc/mkinitcpio.conf > /dev/null; then
        echo "VFIO is already enabled. Quitting..."
        exit 1
    fi
    
    echo "Enabling VFIO..."
    sed -i 's/MODULES=()/#MODULES=()/g' /etc/mkinitcpio.conf
    sed -i 's/#MODULES=(vfio/MODULES=(vfio/g' /etc/mkinitcpio.conf
elif [ "$1" = "off" ]; then
    if grep "#MODULES=(vfio" /etc/mkinitcpio.conf > /dev/null; then
        echo "VFIO is already disabled. Quitting..."
        exit 1
    fi
    
    echo "Disabling VFIO..."
    sed -i 's/#MODULES=()/MODULES=()/g' /etc/mkinitcpio.conf
    sed -i 's/MODULES=(vfio/#MODULES=(vfio/g' /etc/mkinitcpio.conf
else
    echo "Please run with either 'on' or 'off' as command line argument. Quitting..."
    exit 1
fi

sleep 0.5

echo "Regenerating initramfs..."
mkinitcpio -P

echo "Done!"
