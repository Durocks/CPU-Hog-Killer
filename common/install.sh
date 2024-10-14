#!/system/bin/sh

# Print a message to the Magisk installation UI
ui_print "Installing the CPU Hog Killer module..."

# Copy files to their intended paths within the Magisk overlay (using $MODPATH)
cp -r $MODPATH/system/* $MODPATH/

# Set the correct permissions recursively for the system files
# Directories will get 0755 (read and execute for all, write for owner)
# Files will get 0644 (read for all, write for owner)
set_perm_recursive $MODPATH/system 0 0 0755 0644

# Print a message indicating completion
ui_print "Installation of CPU Hog Killer complete."