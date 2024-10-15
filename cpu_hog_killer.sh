#!/system/bin/sh
# set -x

# echo "$(date '+%Y-%m-%d %H:%M:%S') Current shell: $SHELL"

# Configuration
SAMPLE_INTERVAL=10                  # Interval between CPU usage samples in seconds
MONITOR_DURATION=60                 # Total duration to monitor each process (e.g., 300 seconds = 5 minutes)
CPU_THRESHOLD=30                    # CPU usage threshold (in percent)
TOP_PROCESSES_COUNT=5               # Number of top processes to monitor
MEASUREMENTS_LIMIT=5                # Number of measurements before killing the process
INITIAL_SLEEP_TIME=60               # Initial number of seconds to wait for the next run, when the screen is off.
HIGH_PRIORITY_MULTIPLIER=3          # How many times bigger the CPU usage has to be to kill a high priority process, like system_server.
ORIGINAL_SELINUX=$(getenforce)      # Backup the original SELinux Status.
WHITE_LIST="toybox|android.system.suspend-service"

# Function to cleanup measurements
cleanup() {
    # Reset all measurements
    pids=()                   # Clear the PID array
    avg_cpu_usage=()          # Clear the average CPU usage array
    measurements_count=()     # Clear the measurements count array
    unset pids avg_cpu_usage measurements_count
    echo "$(date '+%Y-%m-%d %H:%M:%S') All previous measurements cleared."
}

# Function to check if the system is idle (not charging and screen is locked)
should_monitor() {
    # Get device idle states
    local device_idle_info=$(dumpsys deviceidle)

    # echo "$device_idle_info"

    # Extract relevant values
    local screen_locked=$(echo "$device_idle_info" | grep -o 'mScreenLocked=[^ ]*' | awk -F '=' '{print $2}')
    local charging=$(echo "$device_idle_info" | grep -o 'mCharging=[^ ]*' | awk -F '=' '{print $2}')  # Fixed the missing quote

    # echo "Screen Locked: $screen_locked"
    # echo "Charging: $charging"

    # Check if the system is not charging and screen is locked
    if [[ "$charging" == "false" && "$screen_locked" == "true" ]]; then
        return 0  # System is not charging and screen is locked
    fi
    return 1  # System is either charging or unlocked
}

# Function to trim whitespace and extract the first word
trim_and_extract_command() {
    # Extract the first word from the ARGS string and print it
    echo "$1" | awk '{print $1}'
}

# Function to send notification when a process is killed
send_notification() {
    local cmd=$1
    local avg_cpu=$2
    su -lp 2000 -c "cmd notification post -S bigtext -t 'Title' 'Tag' 'Multiline text'"
}

# Function to monitor CPU usage and analyze the top processes
monitor_and_analyze() {
    cleanup  # Call cleanup before starting the monitoring.
    echo "$(date '+%Y-%m-%d %H:%M:%S') Monitoring CPU usage for $MONITOR_DURATION seconds..."
    TIME_SPENT=0
    while [ "$TIME_SPENT" -lt "$MONITOR_DURATION" ]; do
        # Check if the system is idle at the beginning of each iteration
        if ! should_monitor; then
            echo "System is not idle or it's charging. Exiting monitoring for this cycle."
            cleanup  # Call cleanup after monitoring duration is complete
            return 1 # Exit the function to resume in the next cycle
        fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') Collecting CPU usage snapshot at $TIME_SPENT seconds..."

        # Get the top processes consuming the most CPU by comm
        # top_processes=$(ps -f -eo pid,user,comm,%cpu --sort=-%cpu | head -n "$((TOP_PROCESSES_COUNT + 1))")  # +1 to skip the header
        top_processes=$(top -b -n 1 -o pid,user,comm,%cpu | tail -n +6 | grep -Ev "$WHITE_LIST" | head -n "$((TOP_PROCESSES_COUNT + 1))")  # +1 to skip the header and irrelevant lines

        # Array to track current top processes
        current_top=()

        # Read the output line by line
        while read -r pid user comm cpu; do
            # Filter out empty CPU usage and header
            if [ ! -z "$cpu" ] && [ "$pid" != "PID" ]; then
                # Initialize process data if PID is not already tracked
                if [[ -z "${pids[$pid]}" ]]; then
                    pids[$pid]=$pid
                    avg_cpu_usage[$pid]=0
                    measurements_count[$pid]=0
                fi

                # Update the CPU usage and increment measurement count
                avg_cpu_usage[$pid]=$(echo "${avg_cpu_usage[$pid]} + $cpu" | bc)
                measurements_count[$pid]=$((measurements_count[$pid] + 1))

                # Determine the command name
                if [[ "$comm" == "app_process64" ]]; then
                    # Get ARGS for app_process64, skipping any empty lines
                    args=$(ps -f -eo args -p "$pid" | head -n 2 | tail -n +2)

                    if [ -n "$args" ]; then  # Check if ARGS is not empty
                        cmd=$(trim_and_extract_command "$args")
                        if [ -z "$cmd" ]; then  # If cmd is empty after extraction
                            cmd="app_process64 (no arguments)"  # More informative fallback
                        fi
                    else
                        cmd="app_process64 (no ARGS)"  # More informative fallback
                    fi
                else
                    cmd=$comm
                fi

                current_top+=("$pid $cpu $cmd")

                # Check if the average CPU usage exceeds the threshold and if measurements limit is reached
                if (( measurements_count[$pid] >= MEASUREMENTS_LIMIT )); then
                    avg_cpu=$(echo "${avg_cpu_usage[$pid]} / ${measurements_count[$pid]}" | bc -l)
                    formatted_avg_cpu=$(printf "%.2f" "$avg_cpu")  # Format to two decimal places
                    # Determine the kill condition based on user
                    if [[ "$cmd" == "system_server" ]]; then
                        # For system user, check if avg CPU usage is greater than double the threshold
                        if (( $(echo "$avg_cpu > $((CPU_THRESHOLD * $HIGH_PRIORITY_MULTIPLIER))" | bc -l) )); then
                            echo "$(date '+%Y-%m-%d %H:%M:%S') Killing process $cmd (Average CPU usage: $formatted_avg_cpu%)"
                            kill "$pid"  # Kill the process
                            TIME_SPENT=$((TIME_SPENT - 10))  # Add 10 seconds to monitor duration
                            setenforce 0    # I need to set SELinux Enforcing to Permissive for a second for the notification to show.
                            su
                            su -lp 2000 -c "cmd notification post -S bigtext -t '$cmd Killed' 'Tag' 'Average CPU Usage: $formatted_avg_cpu%'"
                            setenforce $ORIGINAL_SELINUX
                        fi
                    else
                        # For other users, check if avg CPU usage is greater than the threshold
                        if (( $(echo "$avg_cpu > $CPU_THRESHOLD" | bc -l) )); then
                            echo "$(date '+%Y-%m-%d %H:%M:%S') Killing process $cmd (Average CPU usage: $formatted_avg_cpu%)"
                            kill "$pid"  # Kill the process
                            TIME_SPENT=$((TIME_SPENT - 10))  # Add 10 seconds to monitor duration
                            # I need to set SELinux Enforcing to Permissive for a second for the notification to show.
                            setenforce 0    # I need to set SELinux Enforcing to Permissive for a second for the notification to show.
                            su
                            su -lp 2000 -c "cmd notification post -S bigtext -t '$cmd Killed' 'Tag' 'Average CPU Usage: $formatted_avg_cpu%'"
                            setenforce $ORIGINAL_SELINUX
                        fi
                    fi
                fi
            fi
        done <<< "$top_processes"

        # Display the top processes and their average CPU usage
        echo "Top $TOP_PROCESSES_COUNT CPU-consuming processes:"
        for entry in "${current_top[@]}"; do
            read pid cpu cmd <<< "$entry"
            avg_cpu=$(echo "${avg_cpu_usage[$pid]} / ${measurements_count[$pid]}" | bc -l)
            # Format AVG-CPU% to 2 decimal places and round off
            avg_cpu=$(printf "%.2f" "$avg_cpu")
            # Display both current CPU% and AVG-CPU%
            echo "PID: $pid, CPU%: $cpu, AVG-CPU%: $avg_cpu, Command: $cmd, Measurements: ${measurements_count[$pid]}"
        done
        sleep "$SAMPLE_INTERVAL"
        TIME_SPENT=$((TIME_SPENT + SAMPLE_INTERVAL))
    done
    return 0
}

# Main loop
MONITOR_WAIT_TIME=$INITIAL_SLEEP_TIME
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Checking if the system is idle..."
    if should_monitor; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') System is idle."
        
        # Call the monitoring function
        monitor_and_analyze

#         I'm commenting this, because it's not worth it. Running should_monitor every 60 seconds should not consume much CPU.
#        status=$?  # Capture the exit status
#        if [ $status -eq 0 ]; then  # Check if the function returned a zero status (indicating success)
#            echo "Doubling the Monitor Wait Time…"
#            # MONITOR_WAIT_TIME=$((MONITOR_WAIT_TIME * 2))  # Double the wait time after each monitoring session
#            fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') Next monitoring in $MONITOR_WAIT_TIME seconds."
    else
        MONITOR_WAIT_TIME=$INITIAL_SLEEP_TIME  # Reset wait time if the system is active
        echo "$(date '+%Y-%m-%d %H:%M:%S') System is not idle or it's charging. Skipping monitoring for $MONITOR_WAIT_TIME seconds."
    fi
    sleep "$MONITOR_WAIT_TIME"
done
