#!/bin/bash
clear

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'


error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

displaySystemInfo() {
    clear
    
    echo -e "${RED}****** System Information ******"
    
    os=$(uname -o)
    hostname=$(hostname)
    uptime=$(uptime)
    date=$(date)
    info=$(lsb_release -a)
    
    yad --title="System Information" \
    --text="<span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Operating System: </span><span foreground='green'>$os</span>\n\
    <span foreground='black'>--- More Info About OS ---</span>\n\
    <span foreground='green'>$info</span>\n\
    <span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Hostname: </span><span foreground='green'>$hostname</span>\n\
    <span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Uptime: </span><span foreground='green'>$uptime</span>\n\
    <span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Current Date/Time: </span><span foreground='green'>$date</span>\n\
    <span foreground='blue'>_______________________________________</span>" \
    --width=600 --height=400 \
    --button="Back:0" \
    --button="Exit:1" \
    --text-align=left --no-wrap --fontname="monospace" \
    --borders=10 --back='#000000'
    
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        exit 0
    fi
    
    # echo -e "${GREEN}_______________________________________"
    # echo -e "${YELLOW}Operating System: ${GREEN}$os"
    # echo -e "${YELLOW}--- More Info About OS ---"
    # echo -e "${GREEN}$info"
    
    # echo "_______________________________________"
    # echo -e "${YELLOW}Hostname: ${GREEN}$hostname"
    
    # echo "_______________________________________"
    # echo -e "${YELLOW}Uptime: ${GREEN}$uptime"
    
    # echo "_______________________________________"
    # echo -e "${YELLOW}Current Date/Time: ${GREEN}$date"
    
    # echo -e "_______________________________________${NC}\n"
    # read -p "Press Any Key to continue: "
    # clear
    
    
    
}

trap SIGINT

monitorCpuUsage(){
    clear
    echo "**** CPU Usage ****"
    echo "Monitoring CPU usage... Press 'q' and Enter to stop."
    
    while true; do
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
        echo -ne "Current CPU Usage: $cpu_usage% \r"
        sleep 1
        if read -r -t 1 -n 1 input; then
            if [[ "$input" == "q" ]]; then
                echo -e "\nStopping CPU usage monitoring."
                clear
                break
            fi
        fi
    done
}

monitorMemoryUsage(){
    clear
    
    
    # echo -e "${RED}**** Memory Usage ****"
    # echo -e "${GREEN}_______________________________________"
    
    mem_stats=$(free -h | grep Mem)
    total=$(echo "$mem_stats" | awk '{print $2}')
    used=$(echo "$mem_stats" | awk '{print $3}')
    free=$(echo "$mem_stats" | awk '{print $4}')
    
    yad --title="System Information" \
    --width=600 --height=400 \
    --button="Back:0" \
    --button="Exit:1" \
    --text-align=left --no-wrap --fontname="monospace" \
    --borders=10 --back='#000000' \
    --text="<span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Total Memory: </span><span foreground='green'>$total</span>\n\
    <span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Free Memory: </span><span foreground='green'>$free</span>\n\
    <span foreground='blue'>_______________________________________\n</span>\
    <span foreground='black'>Used Memory: </span><span foreground='green'>$used</span>\n\
    <span foreground='blue'>_______________________________________</span>" \
    
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        exit 0
    fi
    
    # echo -e "${YELLOW}Total Memory: ${GREEN}$total"
    # echo -e "${GREEN}_______________________________________"
    # echo -e "${YELLOW}Used Memory: ${GREEN}$used"
    # echo -e "${GREEN}_______________________________________"
    # echo -e "${YELLOW}Free Memory: ${GREEN}$free"
    
    # echo -e "_______________________________________${NC}\n"
    # read -p "Press Any Key to continue: "
    # clear
    
}

monitorDiskSpace(){
    # clear
    # echo -e "${RED}**** Disk Space ****${NC}"
    
    # df -h
    
    # echo -e "_______________________________________${NC}\n"
    # read -p "Press Any Key to continue: "
    # clear
    disk_space=$(df -h)
    
    yad --title="Disk Space" \
    --text-info \
    --width=600 --height=400 \
    --button="Back:0" \
    --button="Exit:1" \
    --text-align=left --no-wrap --fontname="monospace" \
    --borders=10 \
    --text="$disk_space"
    
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        exit 0
    fi
}

# while true; do
#     echo "Please Select Option of the following"
#     echo "I ---> Display System Information || C ---> CPU Usage Monitoring"
#     echo "M ---> Memory Usage Monitoring    || D ---> Disk Space Monitoring"
#     echo "---------- (-1) ---> Exit ----------"

#     read -e -p "Enter your choice: " choice
#     choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

#     case $choice in
#         I) displaySystemInfo
#         ;;
#         C) monitorCpuUsage
#         ;;
#         M) monitorMemoryUsage
#         ;;
#         D) monitorDiskSpace
#         ;;
#         -1) echo "Exiting..."
#             exit
#         ;;
#         *)  clear
#             echo "Please Select to wether to change File Permissions or Owners"
#         ;;
#     esac

# done

while true; do
    operation=$(yad --list \
        --title="System Information" \
        --text="Select an operation:" \
        --column="Operations" \
        "System Information" \
        "CPU Usage Monitoring" \
        "Memory Usage Monitoring" \
        "Disk Space Monitoring" \
        --height=500 --width=700 \
        --button="Back:2" \
        --button="Select:0" \
        --button="Exit:1"
    )
    
    exit_status=$?
    echo $exit_status
    if [ $exit_status -eq 1 ] || [ -z "$operation" ]; then
        exit 0
        elif [  $exit_status -eq 0 ]; then
        case $operation in
            "System Information|")
                displaySystemInfo
            ;;
            "CPU Usage Monitoring|")
                monitorCpuUsage
            ;;
            "Memory Usage Monitoring|")
                monitorMemoryUsage
            ;;
            "Disk Space Monitoring|")
                monitorDiskSpace
            ;;
        esac
        elif [ $exit_status -eq 2 ]; then
        break
    fi
done