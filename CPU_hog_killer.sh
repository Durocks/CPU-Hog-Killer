#!/system/bin/sh

# Configuration
SAMPLE_INTERVAL=10  # Interval between CPU usage samples in seconds
MONITOR_DURATION=300  # Total duration to monitor each process (e.g., 300 seconds = 5 minutes)
CPU_THRESHOLD=30  # CPU usage threshold (in percent)
TOP_PROCESSES_COUNT=5  # Number of top processes to monitor
MEASUREMENTS_LIMIT=15  # Number of measurements before killing the process

# Structure to hold process data
declare -A pids
declare -A avg_cpu_usage
declare -A measurements_count

# Function to check if the system is idle (e.g., screen is off)
is_system_idle() {
    if dumpsys power | grep -q 'mActive=false'; then
        return 0  # System is idle
    else
        return 1  # System is active
    fi
}

# Function to trim whitespace and extract the first word
trim_and_extract_command() {
    # Extract the first word from the ARGS string and print it
    echo "$1" | awk '{print $1}'
}

# Function to monitor CPU usage and analyze the top processes
monitor_and_analyze() {
    echo "Monitoring CPU usage for $MONITOR_DURATION seconds..."
    TIME_SPENT=0
    while [ "$TIME_SPENT" -lt "$MONITOR_DURATION" ]; do
        echo "Collecting CPU usage snapshot at $TIME_SPENT seconds..."

        # Get the top processes consuming the most CPU by comm
        # top_processes=$(ps -f -eo pid,user,comm,%cpu --sort=-%cpu | head -n "$((TOP_PROCESSES_COUNT + 1))")  # +1 to skip the header
        top_processes=$(top -b -n 1 -o pid,user,comm,%cpu | tail -n +6 | head -n "$((TOP_PROCESSES_COUNT + 1))")  # +1 to skip the header and irrelevant lines

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
                    # Determine the kill condition based on user
                    if [[ "$user" == "system" ]]; then
                        # For system user, check if avg CPU usage is greater than double the threshold
                        if (( $(echo "$avg_cpu > $((CPU_THRESHOLD * 2))" | bc -l) )); then
                            echo "Killing system process $pid (Average CPU usage: $avg_cpu%)"
                            kill "$pid"  # Kill the process
                        fi
                    else
                        # For other users, check if avg CPU usage is greater than the threshold
                        if (( $(echo "$avg_cpu > $CPU_THRESHOLD" | bc -l) )); then
                            echo "Killing process $pid (Average CPU usage: $avg_cpu%)"
                            kill "$pid"  # Kill the process
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
            echo "Command name: $cmd" 
            echo "PID: $pid, CPU%: $cpu, AVG-CPU%: $avg_cpu, Command: $cmd, Measurements: ${measurements_count[$pid]}"
        done

        sleep "$SAMPLE_INTERVAL"
        TIME_SPENT=$((TIME_SPENT + SAMPLE_INTERVAL))
    done
}

# Main loop
while true; do
    echo "Checking if the system is idle..."
    if is_system_idle; then
        echo "System is idle. Starting to monitor CPU usage."
        monitor_and_analyze
    else
        echo "System is not idle. Skipping monitoring."
    fi
    # Run every hour (3600 seconds)
    echo "Sleeping for 3600 seconds before the next check..."
    sleep 3600
done