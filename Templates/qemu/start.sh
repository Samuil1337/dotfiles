#!/bin/bash

# Improving performance by fixing CPU frequency scaling governer
#for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
#	echo "performance" > $file
#done

# Stops the display manager (Xorg)
systemctl stop sddm.service

# Unbinds TTYs
for (( i = 0; i < 7; i++)); do
  if test -x /sys/class/vtconsole/vtcon"${i}"; then
      if [ "$(grep -c "frame buffer" /sys/class/vtconsole/vtcon"${i}"/name)" = 1 ]; then
	  echo 0 > /sys/class/vtconsole/vtcon"${i}"/bind
          echo "$i" >> /tmp/vfio-bound-consoles
      fi
  fi
done

# Unbinds the GPUs EFI frame buffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoids race conditions
sleep 5

# Unloads the NVIDIA drivers
modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm_kms_helper
modprobe -r drm

# Cleans up RAM for THP allocation
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/compact_memory

# Wayland takes longer to close properly, so I have to wait more
sleep 5

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_08_00_0
virsh nodedev-detach pci_0000_08_00_1

# Loads the VMs VFIO-PCI drivers
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

# Enables improved IO scheduler for VMs
echo "mq-deadline" > /sys/block/sda/queue/scheduler

# Isolates VM's cores dynamically
systemctl set-property --runtime -- user.slice AllowedCPUs=0-1,8-9
systemctl set-property --runtime -- system.slice AllowedCPUs=0-1,8-9
systemctl set-property --runtime -- init.scope AllowedCPUs=0-1,8-9
