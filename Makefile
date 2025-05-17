HOME_DIR = $(shell echo $$HOME)
PLUGIN_LOCATION = $(HOME_DIR)/.local/share/gnome-shell/extensions/switch-x11-wayland@prasanthc41m.github.com
SUDOERS_FILE = /etc/sudoers.d/session-switcher
USERNAME = $(shell whoami)

all: clean build

build:
	zip switch-x11-wayland.zip extension.js LICENSE metadata.json stylesheet.css x11.sh wayland.sh icons/*

install:
	# Install extension files
	mkdir -p $(PLUGIN_LOCATION)
	cp -R extension.js LICENSE metadata.json stylesheet.css x11.sh wayland.sh icons/ $(PLUGIN_LOCATION)
	chmod +x $(PLUGIN_LOCATION)/x11.sh $(PLUGIN_LOCATION)/wayland.sh
	
	# Setup sudoers configuration
	@echo "Setting up sudoers file for password-less execution of scripts..."
	@echo "This requires sudo access..."
	@echo "$(USERNAME) ALL=(ALL) NOPASSWD: $(PLUGIN_LOCATION)/x11.sh" | sudo tee $(SUDOERS_FILE) > /dev/null
	@echo "$(USERNAME) ALL=(ALL) NOPASSWD: $(PLUGIN_LOCATION)/wayland.sh" | sudo tee -a $(SUDOERS_FILE) > /dev/null
	@sudo chmod 440 $(SUDOERS_FILE)
	@echo "Sudoers configuration installed successfully."
	
	@echo 'Plugin installed with sudo permissions. Restart GNOME Shell.'

uninstall:
	# Remove extension files
	rm -rf $(PLUGIN_LOCATION)
	
	# Remove sudoers file
	@echo "Removing sudoers file (requires sudo)..."
	@if [ -f $(SUDOERS_FILE) ]; then \
		sudo rm $(SUDOERS_FILE); \
		echo "Sudoers configuration removed."; \
	else \
		echo "No sudoers configuration found."; \
	fi
	
	@echo "Uninstallation complete."

reinstall: uninstall install

clean:
	rm -f *.zip

.PHONY: all build install uninstall reinstall clean