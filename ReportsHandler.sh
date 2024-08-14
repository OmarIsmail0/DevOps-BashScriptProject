#!/bin/bash

error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR


RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

get_cpu_usage() {
    local REPORT_FILE=$1
    echo "CPU Usage:" >> "$REPORT_FILE"
    top -bn1 | grep "Cpu(s)" | awk '{print "Total CPU Usage: " 100 - $8 "%"}' >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_memory_usage() {
    local REPORT_FILE=$1
    echo "Memory Usage:" >> "$REPORT_FILE"
    free -h | grep Mem | awk '{print "Total Memory: " $2 ", Used Memory: " $3 ", Free Memory: " $4}' >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_disk_space_usage() {
    local REPORT_FILE=$1
    echo "Disk Space Usage:" >> "$REPORT_FILE"
    df -h >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_system_uptime() {
    local REPORT_FILE=$1
    echo "System Uptime:" >> "$REPORT_FILE"
    uptime -p >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_load_averages() {
    local REPORT_FILE=$1
    echo "Load Averages:" >> "$REPORT_FILE"
    uptime | awk -F'load average:' '{print $2}' >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_top_processes_memory() {
    local REPORT_FILE=$1
    echo "Top Processes by Memory Usage:" >> "$REPORT_FILE"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 10 >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}

get_top_processes_cpu() {
    local REPORT_FILE=$1
    echo "Top Processes by CPU Usage:" >> "$REPORT_FILE"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 10 >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
}


dire=$(yad --file-selection --directory --title="Generating System Metrics Report..." \
    --text="Choose the directory for the report operation.:" --height=500 --width=700 --center \
    --button="Select:0" --button="Cancel:1"
)

if [[ $? -eq 1 ]]; then
    echo "Operation canceled by the user."
    break
fi

echo "Generating System Metrics Report..."
read -ep "Specify the report file location or press Enter to Skip: " output_file

if [[ -d "$dire" ]]; then
    dire+="/report.txt"
else
    dire="report.txt"
fi
echo $dire
echo -e "****** System Metrics Report - $(date) ******" > $dire
echo "----------------------------------------------------------------------" >> $dire
get_cpu_usage "$dire"
get_memory_usage "$dire"
get_disk_space_usage "$dire"
get_system_uptime "$dire"
get_load_averages "$dire"
get_top_processes_memory "$dire"
get_top_processes_cpu "$dire"


echo "Report saved to $dire"

# echo "$get_cpu_usage"
# echo "$get_memory_usage"
# echo "$get_disk_space_usage"
# echo "$get_system_uptime"
# echo "$get_load_averages"
# echo "$get_top_processes_memory"
# echo "$get_top_processes_cpu"
# echo "$get_network_usage"


