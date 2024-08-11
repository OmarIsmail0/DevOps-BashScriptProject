#!/bin/bash

# Error handling function
# error_handler() {
#     echo "Error: Inviald Input"
# }

# trap 'error_handler' ERR

# error_handler() {
#     echo "Error occurred in script at line: $1, command: '$2'"
# }

# trap 'error_handler $LINENO "$BASH_COMMAND"' ERR


# while true; do

#     echo "1) File And Directory Management"
#     echo "2) Permissions And Backup Management"
#     echo "3) System Information Management"
#     echo "4) Reports "
#     echo "-1) To Exit "

#     read -p "Enter your choice: " operation

#     case $operation in
#         1) source ./FileDirectoryOperationsHandler.sh ;;
#         2) source ./PermissionsOwnerBackupOperationsHandler.sh ;;
#         3) source ./SystemInformationHandler.sh ;;
#         4) source ./ReportsHandler.sh ;;
#         -1) echo "Exiting..."
#             exit
#         ;;
#         *) error_handler ;;
#     esac

# done

error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

while true; do
    operation=$(yad --list \
        --title="Main Menu" \
        --text="Select an operation:" \
        --column="Operations" \
        "File And Directory Management" \
        "Permissions And Backup Management" \
        "System Information Management" \
        "Reports" \
        --height=500 --width=700 \
        --button="Select:0" \
        --button="Exit:1"
    )
    
    exit_status=$?
    if [ $exit_status -eq 1 ] || [ -z "$operation" ]; then
        exit 0
        elif [ $exit_status -eq 0 ]; then
        echo "Selected: $operation"
        case $operation in
            "File And Directory Management|")
                source ./FileDirectoryOperationsHandler.sh
            ;;
            "Permissions And Backup Management|")
                source ./PermissionsOwnerBackupOperationsHandler.sh
            ;;
            "System Information Management|")
                source ./SystemInformationHandler.sh
            ;;
            "Reports|")
                source ./ReportsHandler.sh
            ;;
        esac
    fi
done