# GNOME Default Session Switch
A GNOME Shell extension that adds a session indicator to the top panel. The extention allows the user to switch between X11 and Wayland sessions.

1. This extension needs sudo password to execute.
2. You should logout and login or reboot to reflect the change in Windowing System.

## Installation

```
    git clone https://github.com/prasanthc41m/gnome-default-session-switch.git
    cd gnome-default-session-switch
    make install
```

By Default at the login screen, select the "gear" icon and select GNOME on Xorg.

As an alternative, this change can be made by editing a configuration file ```/etc/gdm/custom.conf```.

  Open ```/etc/gdm/custom.conf``` and uncomment the line:

  ```WaylandEnable=false```

  Add the following line to the ```[daemon]``` section:

  ```DefaultSession=gnome-xorg.desktop```

   Save the ```custom.conf``` file.

   This is done by toggleing X11 Wayland Switch extention.

   Logout or reboot to enter the new session.

> **Note**<br>
With the above changes applied, the option to set the GNOME session to use Wayland will actually be removed from the "gear icon" menu on the login screen when you choose X11 as default but will return in Wayland.
<br>
:information_source: Reference:<br>
https://docs.fedoraproject.org/en-US/quick-docs/configuring-xorg-as-default-gnome-session/
