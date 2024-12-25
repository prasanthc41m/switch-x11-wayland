import St from 'gi://St';
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import * as Util from 'resource:///org/gnome/shell/misc/util.js';

let _indicator;

const HomePath = GLib.get_home_dir();
const ExtensionPath = `${HomePath}/.local/share/gnome-shell/extensions/switch-x11-wayland@prasanthc41m.github.com/`;

const SessionIndicator = GObject.registerClass(
    class SessionIndicator extends PanelMenu.Button {
        _init() {
            super._init(0.0, 'Session Indicator');

            let box = new St.BoxLayout();
            this._icon = new St.Icon({
                style_class: 'system-status-icon',
            });
            box.add_child(this._icon);
            this.add_child(box);

            this.initializing = true;

            this.x11MenuItem = new PopupMenu.PopupSwitchMenuItem('Switch to X11', false);
            this.waylandMenuItem = new PopupMenu.PopupSwitchMenuItem('Switch to Wayland', false);

            this.x11MenuItem.connect('toggled', () => {
                if (this.x11MenuItem.state && !this.initializing) {
                    this.waylandMenuItem.setToggleState(false);
                    Util.spawn(['pkexec', 'bash', `${ExtensionPath}x11.sh`]);
                    GLib.setenv('GNOME_SESSION_TYPE', 'x11', true);
                    Main.notify("Session change", "Please reboot to switch default session to X11.");
                    this._updateIconAndMenu('x11');
                }
            });

            this.waylandMenuItem.connect('toggled', () => {
                if (this.waylandMenuItem.state && !this.initializing) {
                    this.x11MenuItem.setToggleState(false);
                    Util.spawn(['pkexec', 'bash', `${ExtensionPath}wayland.sh`]);
                    GLib.setenv('GNOME_SESSION_TYPE', 'wayland', true);
                    Main.notify("Session change", "Please reboot to switch default session to Wayland.");
                    this._updateIconAndMenu('wayland');
                }
            });

            this.menu.addMenuItem(this.x11MenuItem);
            this.menu.addMenuItem(this.waylandMenuItem);

            // Set the initial state based on the current windowing system, but do not execute any change commands
            this._setInitialState();
            this.initializing = false;
        }

        _setInitialState() {
            let sessionType = GLib.getenv('XDG_SESSION_TYPE');
            this._updateIcon(sessionType);
            if (sessionType === 'x11') {
                this.x11MenuItem.setToggleState(true);
                this.waylandMenuItem.setToggleState(false);
            } else if (sessionType === 'wayland') {
                this.x11MenuItem.setToggleState(false);
                this.waylandMenuItem.setToggleState(true);
            }
        }

        _updateIcon(sessionType) {
            let iconName;
            if (sessionType === 'x11') {
                iconName = `${ExtensionPath}icons/x11.svg`;
            } else if (sessionType === 'wayland') {
                iconName = `${ExtensionPath}icons/wayland.svg`;
            }
            this._icon.set_gicon(Gio.icon_new_for_string(iconName));
        }

        _updateIconAndMenu(type = null) {
            let sessionType = type || GLib.getenv('XDG_SESSION_TYPE');
            this._updateIcon(sessionType);
        }
    }
);

let indicator;

export default class X11Extension {
    enable() {
        indicator = new SessionIndicator();
        Main.panel.addToStatusArea('session-indicator-switch', indicator); // Unique role name
    }

    disable() {
        if (indicator) {
            indicator.destroy();
            indicator = null;
        }
    }
}

