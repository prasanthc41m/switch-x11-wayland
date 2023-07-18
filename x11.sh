#!/bin/bash

cat<<EOF>/etc/gdm/custom.conf
# GDM configuration storage

[daemon]
# Uncomment the line below to force the login screen to use Xorg
WaylandEnable=false

# Uncomment the line below to change default login screen to use Xorg
DefaultSession=gnome-xorg.desktop

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
EOF

