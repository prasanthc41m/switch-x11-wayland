const {St, Clutter, GObject, GLib} = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Util = imports.misc.util;
const ExtensionUtils = imports.misc.extensionUtils;
const Gio = imports.gi.Gio;

let _indicator;

const SessionIndicator = GObject.registerClass(
    {GTypeName: 'SessionIndicator'},
    class SessionIndicator extends PanelMenu.Button {
        _init() {
            super._init(0.0, 'Session Indicator');

            let box = new St.BoxLayout();
            this._icon = new St.Icon({style_class: 'session-indicator-icon'});
            box.add(this._icon);
            this.add_child(box);

            this.x11MenuItem = new PopupMenu.PopupSwitchMenuItem('X11', false);
            this.waylandMenuItem = new PopupMenu.PopupSwitchMenuItem('Wayland', false);

            this.x11MenuItem.connect('toggled', () => {
                if (this.x11MenuItem.state) {
                    this.waylandMenuItem.setToggleState(false);
                    const Me = ExtensionUtils.getCurrentExtension();
                    Util.spawn(['pkexec', 'bash', Me.path + '/x11.sh']);
                    GLib.setenv('GNOME_SESSION_TYPE', 'x11', true);
                    Main.notify("Session change", "Please reboot to switch default session to X11.");
                }
            });

            this.waylandMenuItem.connect('toggled', () => {
                if (this.waylandMenuItem.state) {
                    this.x11MenuItem.setToggleState(false);
                    const Me = ExtensionUtils.getCurrentExtension();
                    Util.spawn(['pkexec', 'bash', Me.path + '/wayland.sh']);
                    GLib.setenv('GNOME_SESSION_TYPE', 'wayland', true);
                    Main.notify("Session change", "Please reboot to switch default session to Wayland.");
                }
            });

            this.menu.addMenuItem(this.x11MenuItem);
            this.menu.addMenuItem(this.waylandMenuItem);

            let sessionType = GLib.getenv('GNOME_SESSION_TYPE');
            if (sessionType === 'x11') {
                this.x11MenuItem.setToggleState(true);
                this.waylandMenuItem.setToggleState(false);
            } else if (sessionType === 'wayland') {
                this.x11MenuItem.setToggleState(false);
                this.waylandMenuItem.setToggleState(true);
            }

            this._updateIcon();
        }

        _updateIcon() {
            const Me = ExtensionUtils.getCurrentExtension();
            let iconName;
            let sessionType = GLib.getenv('XDG_SESSION_TYPE');
            if (sessionType === 'x11') {
                iconName = Me.path + '/icons/x11.svg';
                this._icon.gicon = Gio.icon_new_for_string(iconName);
                this.x11MenuItem.setToggleState(true);
                this.waylandMenuItem.setToggleState(false);
            } else if (sessionType === 'wayland') {
                iconName = Me.path + '/icons/wayland.svg';
                this._icon.gicon = Gio.icon_new_for_string(iconName);
                this.x11MenuItem.setToggleState(false);
                this.waylandMenuItem.setToggleState(true);
            }
        }
    }
);

function init() {}

function enable() {
    _indicator = new SessionIndicator();
    Main.panel.addToStatusArea('session-indicator', _indicator);
}

function disable() {
    _indicator.destroy();
}
