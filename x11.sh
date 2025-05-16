#!/bin/bash

ACCOUNTS_DIR="/var/lib/AccountsService/users"

# Loop over each user config file
for FILE in "$ACCOUNTS_DIR"/*; do
    echo "Updating session for: $FILE"
    sudo sed -i 's/^Session=.*/Session=gnome-xorg/' "$FILE"
done
