#!/bin/bash

cat<<EOF>/etc/gdm/custom.conf
#GDM configuration storage

[daemon]
#Uncomment the line below to force the login screen to use Xorg
WaylandEnable=false

#Uncomment the line below to change default login screen to use Xorg
DefaultSession=gnome-xorg.desktop

[security]

[xdmcp]

[chooser]

[debug]
#Uncomment the line below to turn on debugging
#Enable=true
EOF

cat<<EOF>/usr/lib/udev/rules.d/61-gdm.rules
SUBSYSTEM!="pci", GOTO="gdm_pci_device_end"
ACTION!="bind", ACTION!="add", GOTO="gdm_pci_device_end"

# cirrus
ATTR{vendor}=="0x1013", ATTR{device}=="0x00b8", ATTR{subsystem_vendor}=="0x1af4", ATTR{subsystem_device}=="0x1100", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-virtual-gpu", ENV{GDM_MACHINE_HAS_VIRTUAL_GPU}="1", GOTO="gdm_pci_device_end"
# virtio
ATTR{vendor}=="0x1af4", ATTR{device}=="0x1050", ATTR{subsystem_vendor}=="0x1af4", ATTR{subsystem_device}=="0x1100", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-virtual-gpu", ENV{GDM_MACHINE_HAS_VIRTUAL_GPU}="1", GOTO="gdm_pci_device_end"
# qxl
ATTR{vendor}=="0x1b36", ATTR{device}=="0x0100", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-virtual-gpu", ENV{GDM_MACHINE_HAS_VIRTUAL_GPU}="1", GOTO="gdm_pci_device_end"
# vga
ATTR{vendor}=="0x1234", ATTR{device}=="0x1111", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-virtual-gpu", ENV{GDM_MACHINE_HAS_VIRTUAL_GPU}="1", GOTO="gdm_pci_device_end"

# disable Wayland on Hi1710 chipsets
ATTR{vendor}=="0x19e5", ATTR{device}=="0x1711", GOTO="gdm_disable_wayland"

LABEL="gdm_pci_device_end"

# If this machine has a hardware GPU, take note
KERNEL!="card[0-9]*", GOTO="gdm_hardware_gpu_end"
KERNEL=="card[0-9]-*", GOTO="gdm_hardware_gpu_end"
SUBSYSTEM!="drm", GOTO="gdm_hardware_gpu_end"
DRIVERS=="simple-framebuffer", GOTO="gdm_hardware_gpu_end"
IMPORT{parent}="GDM_MACHINE_HAS_VIRTUAL_GPU"
ENV{GDM_MACHINE_HAS_VIRTUAL_GPU}!="1", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-hardware-gpu"
LABEL="gdm_hardware_gpu_end"

# The vendor nvidia driver has multiple modules that need to be loaded before GDM can make an
# informed choice on which way to proceed, so force GDM to wait until NVidia's modules are
# loaded before starting up.
KERNEL!="nvidia", GOTO="gdm_nvidia_end"
SUBSYSTEM!="module", GOTO="gdm_nvidia_end"
ACTION!="add", GOTO="gdm_nvidia_end"
RUN+="/usr/bin/touch /run/udev/gdm-machine-has-vendor-nvidia-driver"

# Import nvidia kernel parameters
IMPORT{program}="/bin/sh -c \"sed -e 's/: /=/g' -e 's/\([^[:upper:]]\)\([[:upper:]]\)/\1_\2/g' -e 's/[[:lower:]]/\U&/g' -e 's/^/NVIDIA_/' /proc/driver/nvidia/params\""

# Check if S0ix-based power management is available
# If it is, there's no need to check for the suspend/resume services
ENV{NVIDIA_ENABLE_S0IX_POWER_MANAGEMENT}=="1", GOTO="gdm_nvidia_suspend_end"

# Check if suspend/resume services necessary for working wayland support is available
TEST{0711}!="/usr/bin/nvidia-sleep.sh", GOTO="gdm_disable_wayland"
TEST{0711}!="/usr/lib/systemd/system-sleep/nvidia", GOTO="gdm_disable_wayland"

ENV{NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS}!="1", GOTO="gdm_disable_wayland"
IMPORT{program}="/bin/sh -c 'echo NVIDIA_HIBERNATE=`systemctl is-enabled nvidia-hibernate`'"
ENV{NVIDIA_HIBERNATE}!="enabled", GOTO="gdm_disable_wayland"
IMPORT{program}="/bin/sh -c 'echo NVIDIA_RESUME=`systemctl is-enabled nvidia-resume`'"
ENV{NVIDIA_RESUME}!="enabled", GOTO="gdm_disable_wayland"
IMPORT{program}="/bin/sh -c 'echo NVIDIA_SUSPEND=`systemctl is-enabled nvidia-suspend`'"
ENV{NVIDIA_SUSPEND}!="enabled", GOTO="gdm_disable_wayland"
LABEL="gdm_nvidia_suspend_end"
LABEL="gdm_nvidia_end"

# If this is a hybrid graphics setup, take note
KERNEL!="card[1-9]*", GOTO="gdm_hybrid_graphics_check_end"
KERNEL=="card[1-9]-*", GOTO="gdm_hybrid_graphics_check_end"
SUBSYSTEM!="drm", GOTO="gdm_hybrid_graphics_check_end"
ACTION!="add", GOTO="gdm_hybrid_graphics_check_end"
IMPORT{program}="/bin/sh -c \"echo GDM_NUMBER_OF_GRAPHICS_CARDS=`ls -1d /sys/class/drm/card[0-9] | wc -l`\""
ENV{GDM_NUMBER_OF_GRAPHICS_CARDS}=="1", RUN+="/usr/bin/rm -f /run/udev/gdm-machine-has-hybrid-graphics"
ENV{GDM_NUMBER_OF_GRAPHICS_CARDS}!="1", RUN+="/usr/bin/touch /run/udev/gdm-machine-has-hybrid-graphics"
LABEL="gdm_hybrid_graphics_check_end"

# Disable wayland in situation where we're in a guest with a virtual gpu and host passthrough gpu
#LABEL="gdm_virt_passthrough_check"
TEST!="/run/udev/gdm-machine-has-hybrid-graphics", GOTO="gdm_virt_passthrough_check_end"
TEST!="/run/udev/gdm-machine-has-virtual-gpu", GOTO="gdm_virt_passthrough_check_end"
TEST!="/run/udev/gdm-machine-has-hardware-gpu", GOTO="gdm_virt_passthrough_check_end"
GOTO="gdm_disable_wayland"
LABEL="gdm_virt_passthrough_check_end"

# Disable wayland when there are multiple virtual gpus
#LABEL="gdm_virt_multi_gpu_check"
TEST!="/run/udev/gdm-machine-has-hybrid-graphics", GOTO="gdm_virt_multi_gpu_check_end"
TEST!="/run/udev/gdm-machine-has-virtual-gpu", GOTO="gdm_virt_multi_gpu_check_end"
TEST=="/run/udev/gdm-machine-has-hardware-gpu", GOTO="gdm_virt_multi_gpu_check_end"
LABEL="gdm_virt_multi_gpu_check_end"

GOTO="gdm_end"

LABEL="gdm_disable_wayland"
RUN+="@libexecdir@/gdm-runtime-config set daemon WaylandEnable false"
GOTO="gdm_end"

LABEL="gdm_end"

EOF

sudo cp -a -u /usr/lib/udev/rules.d/61-gdm.rules /etc/udev/rules.d/
file="/etc/udev/rules.d/61-gdm.rules"
if ! grep -q "^#RUN+=\"/usr/libexec/gdm-runtime-config set daemon PreferredDisplayServer xorg\"" $file; then
    sed -i 's/RUN+=\"\/usr\/libexec\/gdm-runtime-config set daemon PreferredDisplayServer xorg\"/#&/g' $file
fi
if ! grep -q "^#RUN+=\"/usr/libexec/gdm-runtime-config set daemon WaylandEnable false\"" $file; then
    sed -i 's/RUN+=\"\/usr\/libexec\/gdm-runtime-config set daemon WaylandEnable false\"/#&/g' $file
fi
