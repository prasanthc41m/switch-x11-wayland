all: clean build

PLUGIN_LOCATION = ~/.local/share/gnome-shell/extensions/switch-x11-wayland@prasanthc41m.github.com

build:
	zip switch-x11-wayland.zip extension.js LICENSE metadata.json stylesheet.css icons/*

install:
	mkdir -p $(PLUGIN_LOCATION)
	cp -R extension.js LICENSE metadata.json stylesheet.css icons/ $(PLUGIN_LOCATION)
	echo 'Plugin installed. Restart GNOME Shell.'

uninstall:
	rm -rf $(PLUGIN_LOCATION)

reinstall: uninstall install

clean:
	rm -f *.zip
