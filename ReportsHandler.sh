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


echo "Generating System Metrics Report..."
read -ep "Specify the report file location or press Enter to Skip: " output_file

if [[ -d "$output_file" ]]; then
    output_file+="/report.txt"
else
    output_file="report.txt"
fi
echo $output_file
echo -e "****** System Metrics Report - $(date) ******" > $output_file
echo "----------------------------------------------------------------------" >> $output_file
get_cpu_usage "$output_file"
get_memory_usage "$output_file"
get_disk_space_usage "$output_file"
get_system_uptime "$output_file"
get_load_averages "$output_file"
get_top_processes_memory "$output_file"
get_top_processes_cpu "$output_file"


echo "Report saved to $REPORT_FILE"

# echo "$get_cpu_usage"
# echo "$get_memory_usage"
# echo "$get_disk_space_usage"
# echo "$get_system_uptime"
# echo "$get_load_averages"
# echo "$get_top_processes_memory"
# echo "$get_top_processes_cpu"
# echo "$get_network_usage"


