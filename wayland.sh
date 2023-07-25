#!/bin/bash

cat<<EOF>/etc/gdm/custom.conf
# GDM configuration storage

[daemon]
# Uncomment the line below to force the login screen to use Xorg
#WaylandEnable=false
WaylandEnable=true

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
EOF

file="/etc/udev/rules.d/61-gdm.rules"
if ! grep -q "^#RUN+=\"/usr/libexec/gdm-runtime-config set daemon PreferredDisplayServer xorg\"" $file; then
    sed -i 's/RUN+=\"\/usr\/libexec\/gdm-runtime-config set daemon PreferredDisplayServer xorg\"/#&/g' $file
fi
if ! grep -q "^#RUN+=\"/usr/libexec/gdm-runtime-config set daemon WaylandEnable false\"" $file; then
    sed -i 's/RUN+=\"\/usr\/libexec\/gdm-runtime-config set daemon WaylandEnable false\"/#&/g' $file
fi
