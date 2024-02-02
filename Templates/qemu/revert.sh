#!/bin/bash

# Re-enables all cores dynamically
systemctl set-property --runtime -- user.slice AllowedCPUs=0-15
systemctl set-property --runtime -- system.slice AllowedCPUs=0-15
systemctl set-property --runtime -- init.scope AllowedCPUs=0-15

# Re-enables better IO scheduler for general use and SSDs
echo "bfq" > /sys/block/sda/queue/scheduler

# Unload the VMs VFIO-PCI drivers
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Avoid race conditions
sleep 2

# Re-attaches the GPU to the host
virsh nodedev-reattach pci_0000_08_00_1
virsh nodedev-reattach pci_0000_08_00_0

# Loads the NVIDIA drivers
modprobe drm
modprobe drm_kms_helper
modprobe i2c_nvidia_gpu
modprobe nvidia
modprobe nvidia_modeset
modprobe nvidia_drm
modprobe nvidia_uvm

# Rebinds the EFI frame buffer to the GPU
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

# Rebinds the TTYs
input="/tmp/vfio-bound-consoles"
while read -r consoleNumber; do
    if test -x /sys/class/vtconsole/vtcon"${consoleNumber}"; then
        if [ "$(grep -c "frame buffer" "/sys/class/vtconsole/vtcon${consoleNumber}/name")" = 1 ]; then
	    echo 1 > /sys/class/vtconsole/vtcon"${consoleNumber}"/bind
        fi
    fi
done < "$input"

# Starts Xorg again
systemctl start sddm.service

# Lowering power consumption by resetting frequency governer
#for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
#	echo "powersave" > $file
#done
