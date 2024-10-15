#!/system/bin/sh
# set -x 
resetprop -w sys.boot_completed 0
MODDIR=${0%/*}

# Wait until /sdcard/ exists and is accessible
until [ -d "/sdcard/" ]; do
    echo "/sdcard/ is not accessible yet. Waiting..."
    sleep 2
done
# Now that /sdcard/ is accessible, proceed
echo "/sdcard/ is accessible."

# Redirect output to a log file
rm /sdcard/cpu_hog_killer.log
LOGFILE="/sdcard/cpu_hog_killer.log"
exec > "$LOGFILE" 2>&1

# Make the log file readable for debugging
chmod 664 "$LOGFILE"

# Log that the script has started
echo "Service script started."

# Wait until /system/bin/sh exists and is accessible
until [ -x "/system/bin/sh" ]; do
    echo "/system/bin/sh is not accessible yet. Waiting..."
    sleep 2
done
echo "/system/bin/sh is now accessible."

# Check MODPATH
MODPATH="$MODDIR"
echo "MODPATH: $MODPATH"

# Start the CPU hog killer script with an absolute path
chmod 755 "$MODPATH/cpu_hog_killer.sh"
/system/bin/sh "$MODPATH/cpu_hog_killer.sh"

# Log that the script has started
echo "Service script started."
