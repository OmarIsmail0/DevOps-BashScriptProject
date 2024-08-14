#!/bin/bash
clear

error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

BACKUP_DIR="./BACKUP"
mkdir -p "$BACKUP_DIR"


changePermissionsOperation() {
    while true; do
        file_path=$(yad --file-selection --title="Select File/Directory" \
            --text="Choose the file/directory:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        permission_action=$(yad --list \
            --title="Permission Action" \
            --text="Choose the action to perform on permissions:" \
            --column="Action" \
            "Add" \
            "Remove" \
            "Set" \
            --height=200 --width=300 \
            --button="Select:0" \
            --button="Back:1"
        )
        
        exit_status=$?
        if [ $exit_status -eq 1 ] || [ -z "$permission_action" ]; then
            return
        fi
        
        case $permission_action in
            "Add|")
                perm_mode="+"
            ;;
            "Remove|")
                perm_mode="-"
            ;;
            "Set|")
                perm_mode="="
            ;;
        esac
        
        permissions=$(yad --form --title="Change Permissions" \
            --field="Owner User Permissions (e.g., wrx):" \
            --field="Group User Permissions (e.g., wrx):" \
            --field="Other User Permissions (e.g., wrx):"
        )
        
        if [ $? -ne 0 ]; then
            return
        fi
        
        owner_user=$(echo "$permissions" | awk -F'|' '{print $1}')
        owner_group=$(echo "$permissions" | awk -F'|' '{print $2}')
        owner_other=$(echo "$permissions" | awk -F'|' '{print $3}')
        
        if [[ "$permission_action" == "Set" ]]; then
            permission_mode=$(yad --entry --title="Set Permissions" \
                --text="Enter the permission mode (e.g., 755, 644):" \
            --width=400)
            if [[ ! -z "$permission_mode" ]]; then
                if [[ "$permission_mode" =~ ^[0-7]{1,3}$ ]]; then
                    chmod "$permission_mode" "$file_path" 2>/dev/null
                    if [[ $? -ne 0 ]]; then
                        yad --error --title="Error" --text="Failed to set file permissions."
                    else
                        yad --info --title="Success" --text="Permissions set."
                    fi
                    return
                else
                    yad --error --title="Error" --text="Invalid permission mode. Please enter a valid octal number (e.g., 755)."
                    return
                fi
            fi
        fi
        echo "u$perm_mode$owner_user" "$file_path"
        echo 'chmod u$perm_mode$owner_user $file_path'
        
        if [[ ! -z "$owner_user" ]]; then
            chmod "u$perm_mode$owner_user" "$file_path" 2>/dev/null
        fi
        if [[ ! -z "$owner_group" ]]; then
            chmod "g$perm_mode$owner_group" "$file_path" 2>/dev/null
        fi
        if [[ ! -z "$owner_other" ]]; then
            chmod "o$perm_mode$owner_other" "$file_path" 2>/dev/null
        fi
        yad --info --title="Success" --text="Permissions changed."
        
    done
    
}

changeOwnerOperation() {
    while true; do
        file_path=$(yad --file-selection --title="Select File/Directory" \
            --text="Choose the file/directory:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        owner_user=$(yad --entry --title="Change Owner" --text="Enter the owner user (e.g., Omar):" --width=400)
        owner_group=$(yad --entry --title="Change Owner" --text="Enter the owner group (e.g., Finance):" --width=400)
        
        if [[ -n "$owner_user" || -n "$owner_group" ]]; then
            chown "$owner_user:$owner_group" "$file_path" 2>/dev/null
            if [[ $? -ne 0 ]]; then
                yad --error --title="Error" --text="Failed to change owner."
            else
                yad --info --title="Success" --text="Owner changed."
            fi
        else
            yad --info --title="Cancelled" --text="Owner change cancelled."
        fi
    done
}

createBackup() {
    while true; do
        
        file_path=$(yad --file-selection --title="Select File/Directory" \
            --text="Choose the file/directory to create backup" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        backup_name=$(basename "$file_path").tar.gz
        echo $backup_name
        tar -czvf "$backup_name" "$file_path" 2>/dev/null
        sleep 1
        if [[ $? -ne 0 ]]; then
            yad --error --title="Error" --text="Failed to create backup."
            break
        else
            if [[ -f "$BACKUP_DIR/$backup_name" || -d "$BACKUP_DIR/$backup_name" ]]; then
                yad --title="Confirm Overwrite" --width=400 --height=50 --center \
                --question --text="Destination File/Directory '$dest/$filename' already exists. Overwrite?"
                if [[ $? -eq 0 ]]; then
                    clear
                    mv "$backup_name" "$BACKUP_DIR"
                    yad --info --title="Success" --text="Backup created successfully: $backup_name"
                    return
                else
                    yad --title="Copy Operation Canceled" --width=400 --height=50 --info --text="Copy Operation Canceled"
                    return
                fi
            else
                mv "$backup_name" "$BACKUP_DIR"
                yad --info --title="Success" --text="Backup created successfully: $backup_name"
                break
            fi
            
        fi
    done
}

restoreBackup(){
    while true; do
        
        file_path=$(yad --file-selection --file --title="Select File/Directory" \
            --text="Choose the file/directory:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        # action=$(yad --form \
        #     --title="Restore Backup" \
        #     --text="Choose an action: \n $(ls -lh "$BACKUP_DIR")" \
        #     --field="File Name (e.g. filename.tar.gz):\n" \
        #     --button="Restore:2" \
        #     --button="Back:1" \
        #     --button="Exit:0" \
        #     --width=600 --height=400
        # )
        
        # if [ $? -e 0 ]; then
        #     exit 0
        # fi
        
        # if [ $? -e 1 ]; then
        #     break
        # fi
        
        # file_path=$(echo "$action" | awk -F'|' '{print $1}')
        echo "$file_path"
        # if [[ ! -d "$file_path" ]]; then
        #     if [[ ! -e "$BACKUP_DIR/$file_path" ]]; then
        #         yad --error --title="Error" --text="File not found in backup directory."
        #         continue
        #     fi
        
        tar -xzvf "$file_path" -C "$BACKUP_DIR/"
        if [[ $? -ne 0 ]]; then
            yad --error --title="Error" --text="Failed to restore backup."
        else
            yad --info --title="Success" --text="Backup restored successfully to: $BACKUP_DIR"
        fi
        break
        # fi
        
    done
}

while true; do
    operation=$(yad --list \
        --title="Permissions and Backup" \
        --text="Select an operation:" \
        --column="Operations" \
        "Permissions" \
        "Owners" \
        "Backup" \
        "Restore" \
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
            "Permissions|")
                changePermissionsOperation
            ;;
            "Owners|")
                changeOwnerOperation
            ;;
            "Backup|")
                createBackup
            ;;
            "Restore|")
                restoreBackup
            ;;
        esac
        elif [ $exit_status -eq 2 ]; then
        break
    fi
done


cmdCode() {
    changePermissionsOperation() {
        
        read -e -p "Enter the file path: " file_path
        
        if [[ ! -e "$file_path" ]]; then
            echo "File not found"
            continue
        fi
        
        read -p "Enter the permission mode (e.g., 755, 644) or press Enter to skip: " permission_mode
        
        if [[ ! -z "$permission_mode" ]]; then
            if [[ "$permission_mode" =~ ^[0-7]{1,3}$ ]]; then
                chmod "$permission_mode" "$file_path" 2>/dev/null
                if [[ $? -ne 0 ]]; then
                    echo "Error: Failed to change file permissions."
                    return
                else
                    echo "Permissions changed"
                    return
                fi
            else
                echo "Invalid permission mode. Please enter a valid octal number (e.g., 755)"
                return
            fi
        fi
        
        echo "(+) to add,   (-) to remove, and (=) to set"
        echo "(w) to write, (r) to read,   and (x) to execute"
        
        read -p "Enter the owner user permissions (e.g., +rw) or press Enter to skip: " owner_user
        
        read -p "Enter the group user permissions (e.g., +rwx) or press Enter to skip: " owner_group
        
        read -p "Enter the other user permissions (e.g., +wx) or press Enter to skip: " owner_other
        
        if [[ ! (-z "$owner_user") || ! (-z "$owner_group") || ! (-z "$owner_other") ]]; then
            if [[ ! -z "$owner_user" ]]; then
                chmod "u$owner_user" "$file_path" 2>/dev/null
                if [[ $? -ne 0 ]]; then
                    echo "Error: Failed to change user permissions."
                    return
                fi
            fi
            if [[ ! -z "$owner_group" ]]; then
                chmod "g$owner_group" "$file_path" 2>/dev/null
                if [[ $? -ne 0 ]]; then
                    echo "Error: Failed to change group permissions."
                    return
                fi
            fi
            if [[ ! -z "$owner_other" ]]; then
                chmod "o$owner_other" "$file_path" 2>/dev/null
                if [[ $? -ne 0 ]]; then
                    echo "Error: Failed to change other permissions."
                    return
                fi
            fi
            clear
            echo "Permissions changed"
        fi
    }
    
    changeOwnerOperation() {
        read -e -p "Enter the file path: " file_path
        
        if [[ ! -e "$file_path" ]]; then
            echo "File not found"
            return
        fi
        
        read -p "Enter the owner user (e.g. Omar) or press Enter to skip: " owner_user
        
        read -p "Enter the owner group (e.g. Finance) or press Enter to skip: " owner_group
        
        if [[ -n "$user_ownership" || -n "$group_ownership" ]]; then
            chown "$user_ownership:$group_ownership" "$target" 2>/dev/null
            break
        else
            echo "Permission ownership has been cancelled"
            break
        fi
    }
    createBackup() {
        while true; do
            clear
            read -e -p "Enter the directory path or (0) to back: " file_path
            
            if [[ "$file_path" = 0 ]]; then
                break
            fi
            
            if [[ ! -d "$file_path" ]]; then
                echo "This isn't a directory"
                continue
            fi
            
            backup_name=$(echo "$file_path" | awk -F'/' '{print $NF}').tar.gz
            echo "$backup_name"
            tar -czvf "$backup_name" "$file_path" 2>/dev/null
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to create backup."
                continue
            fi
            
            clear
            mv "$backup_name" "$BACKUP_DIR"
            echo "Backup created successfully: $backup_name"
            break
        done
    }
    
    restoreBackup(){
        clear
        
        while true; do
            
            read -e -p "Enter the file name (e.g. filename.tar.gz) or (0) or (L) to back: " file_path
            
            if [[ "$file_path" = 0 ]]; then
                break
            fi
            
            if [[ "$file_path" = "L" ]]; then
                clear
                ls -lh "$BACKUP_DIR"
                continue
            fi
            
            echo "$BACKUP_DIR/$file_path"
            
            if [[ ! -e "$BACKUP_DIR/$file_path" ]]; then
                echo "File not found"
                continue
            fi
            
            tar -xzvf "$BACKUP_DIR/$file_path" -C "$BACKUP_DIR/"
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to restore backup."
                continue
            fi
            
            echo "Backup restored successfully to: $BACKUP_DIR"
            break
            
        done
    }
    
    while true; do
        echo "Please Select Option of the following"
        echo "P ---> Permissions || O ---> Owners "
        echo "B ---> Backup      || R ---> Restore"
        echo "---------- (-1) ---> Exit ----------"
        
        read -e -p "Enter your choice: " choice
        choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
        
        case $choice in
            P) changePermissionsOperation
                break
            ;;
            O) changeOwnerOperation
                break
            ;;
            B) createBackup
                break
            ;;
            R) restoreBackup
                break
            ;;
            -1) echo "Exiting..."
                exit
                break
            ;;
            *)  clear
                echo "Please Select to wether to change File Permissions or Owners"
            ;;
        esac
        
    done
}



