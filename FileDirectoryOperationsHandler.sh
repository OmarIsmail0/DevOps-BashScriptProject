#!/bin/bash
clear

# Error handling function
# error_handler() {
#     clear
#     echo "error: Invalid choice."
# }

error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

createOperation() {
    while true; do
        path=$(yad --file-selection --directory --title="Select Directory" \
            --text="Choose the directory:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$path" ]]; then
            echo "Directory selected: $path"
        else
            echo "No directory selected."
        fi
        
        filename=$(yad --title="Enter File/Folder name" --width=400 --height=50 --center \
            --entry --text="Enter the File/Folder to create:" \
        --button="Enter:0" --button="Cancel:1")
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        operation=$(yad --list \
            --title="Select File or Directory" \
            --text="Select an operation:" \
            --column="Operations" \
            "File" "Directory" \
            --height=500 --width=700 --center \
            --button="Back:2" \
            --button="Select:0" \
            --button="Exit:1"
        )
        
        exit_status=$?
        
        if [ $exit_status -eq 1 ] || [ -z "$operation" ]; then
            exit 0
            elif [  $exit_status -eq 0 ]; then
            case $operation in
                "File|")
                    if [ ! -f "$path/$filename" ]; then
                        touch "$path/$filename"
                        yad --info --title="Success" --text="File '$path/$filename' created." --width=400 --height=20 --center --button="Close:0"
                        return
                    else
                        yad --error --title="Error" --text="File '$path/$filename' already exists." --width=400 --height=20 --center --button="Close:0"
                        return
                    fi
                ;;
                "Directory|") echo "test"
                    if [ ! -d "$path/$filename" ]; then
                        mkdir -p "$path/$filename"
                        yad --info --title="Success" --text="Directroy '$path/$filename' created." --width=400 --height=20 --center --button="Close:0"
                        return
                    else
                        yad --error --title="Error" --text="Directroy '$path/$filename' already exists." --width=400 --height=20 --center --button="Close:0"
                        return
                    fi
                ;;
            esac
            elif [ $exit_status -eq 2 ]; then
            break
        fi
    done
}

copyOperation() {
    while true; do
        src=$(yad --file-selection --title="Source Directory." \
            --text="Choose the source file/directory for the copy operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$src" ]]; then
            echo "Directory selected: $src"
        else
            echo "No directory selected."
        fi
        
        dest=$(yad --file-selection --directory --title="Destination Directory." \
            --text="Choose the destination directory for the copy operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$dest" ]]; then
            echo "Directory selected: $dest"
        else
            echo "No directory selected."
        fi
        
        filename=$(basename "$src")
        
        if [[ -f "$dest/$filename" || -d "$dest/$filename" ]]; then
            yad --title="Confirm Overwrite" --width=400 --height=50 --center \
            --question --text="Destination File/Directory '$dest/$filename' already exists. Overwrite?"
            if [[ $? -eq 0 ]]; then
                clear
                cp "$src" "$dest/$filename"
                yad --title="File/Directory Copied" --width=400 --height=50 --center \
                --info --text="File/Directory '$src' copied to '$dest/$filename'."
                return
            else
                yad --title="Copy Operation Canceled" --width=400 --height=50 --info --text="Copy Operation Canceled"
                return
            fi
        else
            clear
            cp "$src" "$dest/$filename"
            yad --title="File/Directory Copied" --width=400 --height=50 --center \
            --info --text="File/Directory '$src' copied to '$dest/$filename'."
            return
        fi
    done
}

renameOperation() {
    
    while true; do
        src=$(yad --file-selection --title="Source Directory." \
            --text="Choose the file/directory for the rename operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$src" ]]; then
            echo "Directory selected: $src"
        else
            echo "No directory selected."
        fi
        
        newName=$(yad --title="File/Folder Name" --width=400 --height=50 --center \
            --entry --text="Enter the new File/Folder name:" \
        --button="Enter:0" --button="Cancel:1")
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
        fi
        
        path=$(dirname "$src")
        oldName=$(basename "$src")
        
        if [[ -f "$path/$newName" || -d "$path/$newName" ]]; then
            yad --title="Confirm Overwrite" --width=400 --height=20 --center \
            --question --text="File/Directory '$newName' already exists. Overwrite?"
            if [[ $? -eq 0 ]]; then
                clear
                mv "$src" "$path/$newName"
                yad --title="File/Directory Renamed" --width=400 --height=20 --center \
                --info --text="File/Directory '$src' renamed to '$newName'."
                return
            else
                yad --title="Copy Operation Canceled" --width=400 --height=20 --info --text="Copy Operation Canceled"
                return
            fi
        else
            clear
            mv "$src" "$path/$newName"
            yad --title="File/Directory Renamed" --width=400 --height=20 --center \
            --info --text="File/Directory '$src' renamed to '$newName'."
            return
        fi
    done
}

removeOperation() {
    while true; do
        file=$(yad --file-selection --title="File/Directory Delete." \
            --text="Choose the file/directory for the deletion operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$file" ]]; then
            echo "Directory selected: $file"
        else
            echo "No directory selected."
        fi
        
        filename=$(basename "$file")
        
        yad --title="Confirm Deletion" --width=400 --height=20 --center \
        --question --text="Are you sure you want to delete File/Directory '$filename'?"
        if [[ $? -eq 0 ]]; then
            clear
            rm -r "$file"
            yad --title="File/Directory Deleted" --width=400 --height=20 --center \
            --info --text="File/Directory '$filename' Deleted."
            return
        else
            yad --title="Copy Operation Canceled" --width=400 --height=20 --info --text="Copy Operation Canceled"
            return
        fi
    done
}

moveOperation() {
    
    while true; do
        src=$(yad --file-selection --title="Source Directory." \
            --text="Choose the source file/directory for the move operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$src" ]]; then
            echo "Directory selected: $src"
        else
            echo "No directory selected."
        fi
        
        dest=$(yad --file-selection --directory --title="Destination Directory." \
            --text="Choose the destination directory for the move operation.:" --height=500 --width=700 --center \
            --button="Select:0" --button="Cancel:1"
        )
        
        if [[ $? -eq 1 ]]; then
            echo "Operation canceled by the user."
            break
            elif [[ -n "$dest" ]]; then
            echo "Directory selected: $dest"
        else
            echo "No directory selected."
        fi
        
        filename=$(basename "$src")
        
        yad --title="Confirm Move" --width=400 --height=20 --center \
        --question --text="Are you sure you want to move File/Directory '$filename'?"
        if [[ $? -eq 0 ]]; then
            if [[ -f "$dest/$filename" || -d "$dest/$filename" ]]; then
                yad --title="Confirm Overwrite" --width=400 --height=50 --center \
                --question --text="Destination File/Directory '$filename' already exists. Overwrite?"
                if [[ $? -eq 0 ]]; then
                    clear
                    cp -r -i "$src" "$dest/$filename"
                    rm -r "$src"
                    yad --title="File/Directory Moved" --width=400 --height=20 --center \
                    --info --text="File/Directory '$src' moved to '$filename'."
                    return
                else
                    yad --title="Move Operation Canceled" --width=400 --height=20 --info --text="Move Operation Canceled"
                    return
                fi
            else
                cp -r -i "$src" "$dest/$filename"
                rm -r "$src"
                yad --title="File/Directory Moved" --width=400 --height=20 --center \
                --info --text="File/Directory '$src' moved to '$filename'."
                return
            fi
        else
            yad --title="Move Operation Canceled" --width=400 --height=20 --info --text="Copy Operation Canceled"
            return
        fi
    done
    
}

searchOperation(){
    while true; do
        
        searchParams=$(yad --form --title="Search Criteria" --height=500 --width=700 \
            --field="Directory":DIR \
            --field="File Name": \
            --field="File Type (e.g., *.txt)": \
            --field="Size (e.g., +1M, -500K)": \
            --field="Modification Time (e.g., +7):": \
        )
        
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        directory=$(echo "$searchParams" | awk -F'|' '{print $1}')
        filename=$(echo "$searchParams" | awk -F'|' '{print $2}')
        filetype=$(echo "$searchParams" | awk -F'|' '{print $3}')
        size=$(echo "$searchParams" | awk -F'|' '{print $4}')
        modified_after=$(echo "$searchParams" | awk -F'|' '{print $5}')
        
        
        find_command="find '$directory' "
        
        
        if [ -n "$filename" ]; then
            find_command+=" -name '*$filename*'"
        fi
        
        if [ -n "$filetype" ]; then
            find_command+=" -name '*.$filetype'"
        fi
        
        if [ -n "$size" ]; then
            find_command+=" -size $size"
        fi
        
        if [ -n "$date" ]; then
            find_command+=" -mtime $modified_after"
        fi
        
        echo "$find_command"
        search_results=$(eval $find_command)
        
        if [[ -n "$search_results" ]]; then
            yad --title="Search Results" --height=500 --width=700 --center --text-info --wrap \
            --text="Files found:\n$search_results"
            break
        else
            yad --title="Search Results" --height=500 --width=700 --center \
            --info --text="No files found matching the criteria."
            break
        fi
    done
}

while true; do
    operation=$(yad --list \
        --title="File and Directory Operations" \
        --text="Select an operation:" \
        --column="Operations" \
        "Create" \
        "Copy" \
        "Delete" \
        "Move" \
        "Rename" \
        "Search" \
        --height=500 --width=700 \
        --button="Back:2" \
        --button="Select:0" \
        --button="Exit:1"
    )
    
    exit_status=$?
    
    if [ $exit_status -eq 1 ] || [ -z "$operation" ]; then
        exit 0
        elif [  $exit_status -eq 0 ]; then
        case $operation in
            "Create|") createOperation ;;
            "Copy|")   copyOperation   ;;
            "Delete|") removeOperation ;;
            "Move|")   moveOperation   ;;
            "Rename|") renameOperation ;;
            "Search|") searchOperation ;;
        esac
        elif [ $exit_status -eq 2 ]; then
        break
    fi
    
    
done


oldCode(){
    
    createOperation() {
        
        local operationType=$1
        if [[ "$operationType" =~ "F" ]]; then
            read -e -p "Enter the filename to create: " filename
            read -e -p "Enter the path to create the file in (optional): " path
            
            # Set default path to current directory if not provided
            path=${path:-.}
            
            # Check if the provided path is valid
            if [ -d "$path" ]; then
                if [ ! -f "$path/$filename" ]; then
                    touch "$path/$filename"
                    clear
                    echo "*** File '$path/$filename' created. ***"
                else
                    clear
                    echo "File '$path/$filename' already exists."
                fi
            else
                clear
                echo "Invalid path: '$path'"
            fi
            
            elif [[ "$operationType" =~ "D" ]]; then
            read -e -p "Enter the directory name to create: " dirname
            read -e -p "Enter the path to create the directory in (optional): " path
            
            # Set default path to current directory if not provided
            path=${path:-.}
            
            # Check if the provided path is valid
            if [ -d "$path" ]; then
                if [ ! -d "$path/$dirname" ]; then
                    mkdir -p "$path/$dirname"
                    clear
                    echo "*** Directory '$path/$dirname' created. ***"
                else
                    clear
                    echo "Directory '$path/$dirname' already exists."
                fi
            else
                clear
                echo "Invalid path: '$path'"
            fi
        fi
    }
    
    copyOperation() {
        local operationType=$1
        if [[ "$operationType" =~ "F" ]]; then
            read -e -p "Enter the source file path: " src
            read -e -p "Enter the destination directory path: " dest
            
            if [ -f "$src" ]; then
                filename=$(basename "$src")
                if [ -d "$dest" ]; then
                    if [ -f "$dest/$filename" ]; then
                        read -e -p "Destination file '$dest/$filename' already exists. Overwrite? (y/n): " confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            cp "$src" "$dest/$filename"
                            clear
                            echo "*** File '$src' copied to '$dest/$filename'. ***"
                        else
                            clear
                            echo "Copy operation cancelled."
                        fi
                    else
                        cp "$src" "$dest/$filename"
                        clear
                        echo "*** File '$src' copied to '$dest/$filename'. ***"
                    fi
                else
                    clear
                    echo "Invalid destination directory: '$dest'"
                fi
            else
                clear
                echo "Source file '$src' does not exist."
            fi
            
            elif [[ "$operationType" =~ "D" ]]; then
            read -e -p "Enter the source directory path: " src
            read -e -p "Enter the destination directory path: " dest
            
            if [ -d "$src" ]; then
                dirname=$(basename "$src")
                if [ -d "$dest" ]; then
                    cp -r -i "$src" "$dest/$dirname"
                    echo "*** Directory '$src' copied to '$dest/$dirname'. ***"
                else
                    echo "Invalid destination directory: '$dest'"
                fi
            else
                echo "Source directory '$src' does not exist."
            fi
        fi
    }
    
    renameOperation() {
        local operationType=$1
        
        while true; do
            echo "To Return Enter (0)"
            
            read -e -p "Enter the path where the file/folder is located (optional): " path
            if [ "$path" -eq 0 ]; then
                clear
                echo "Backing..."
                break
            fi
            read -e -p "Enter the file/folder to rename: " oldname
            if [ "$oldname" -eq 0 ]; then
                clear
                echo "Backing..."
                break
            fi
            read -e -p "Enter the new file/folder: " newname
            if [ "$newname" -eq 0 ]; then
                clear
                echo "Backing..."
                break
            fi
            
            
            path=${path:-.}
            
            if [ -d "$path" ]; then
                if [[ -f "$path/$oldname" || -d "$path/$oldname" ]]; then
                    read -p "Are you sure you want to rename the file/folder '$path/$oldname' to '$path/$newname'? (y/n): " confirm
                    case $confirm in
                        y | Y ) mv "$path/$oldname" "$path/$newname"
                            clear
                            echo "*** file/folder '$path/$oldname' renamed to '$path/$newname'. ***"
                        break;;
                        n | N ) echo "Renaming cancelled."
                        break;;
                        * ) echo "Invalid input. Please enter 'y' or 'n'."
                        break;;
                    esac
                    
                else
                    # clear
                    echo "file/folder '$path/$oldname' does not exist."
                fi
            else
                # clear
                echo "Invalid path: '$path'"
            fi
            
        done
        
    }
    
    removeOperation() {
        local operationType=$1
        
        read -e -p "Enter the file/folder to remove: " filename
        
        if [[ -f "$filename" || -d "$filename" ]]; then
            # Ask for confirmation before deletion
            read -e -p "Destination file '$dest/$filename' already exists. Overwrite? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -r "$filename"
                # clear
                echo "*** File/Folder '$filename' removed. ***"
            else
                # clear
                echo "Deletion operation cancelled."
            fi
        else
            # clear
            echo "File/Folder '$filename' does not exist."
        fi
    }
    
    moveOperation() {
        local operationType=$1
        
        if [[ "$operationType" =~ "F" ]]; then
            read -e -p "Enter the path where the file is located (optional): " srcPath
            read -e -p "Enter the filename to move: " oldname
            read -e -p "Enter the destination path (where you want to move the file): " destPath
            read -e -p "Enter the new filename (optional, leave blank to keep the same name): " newname
            
            srcPath=${srcPath:-.}
            destPath=${destPath:-.}
            
            if [ -d "$srcPath" ]; then
                if [ "$(pwd)" != "$srcPath" ]; then
                    cd "$srcPath" || { echo "Failed to change directory to '$srcPath'"; return 1; }
                fi
                
                if [ -f "$oldname" ]; then
                    destFile="$destPath/${newname:-$oldname}"
                    
                    mkdir -p "$destPath"
                    
                    read -p "Are you sure you want to move the file '$oldname' to '$destFile'? (y/n): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        if [ -f "$destPath/$oldname" ]; then
                            read -p "file '$oldname' already exits do you want to override? (y/n): " confirmO
                            if [[ "$confirmO" =~ ^[Yy]$ ]]; then
                                mv "$oldname" "$destFile"
                                clear
                                echo "*** File '$oldname' moved to '$destFile'. ***"
                            else
                                clear
                                echo "File move cancelled."
                            fi
                        fi
                    else
                        clear
                        echo "File move cancelled."
                    fi
                else
                    clear
                    echo "File '$oldname' does not exist."
                fi
            else
                clear
                echo "Invalid source path: '$srcPath'"
            fi
            
            elif [[ "$operationType" =~ "D" ]]; then
            read -e -p "Enter the path where the directory is located (optional): " srcPath
            read -e -p "Enter the directory name to move: " oldname
            read -e -p "Enter the destination path (where you want to move the directory): " destPath
            read -e -p "Enter the new directory name (optional, leave blank to keep the same name): " newname
            
            srcPath=${srcPath:-.}
            destPath=${destPath:-.}
            
            if [ -d "$srcPath" ]; then
                
                if [ -d "$oldname" ]; then
                    destDir="$destPath/${newname:-$oldname}"
                    mkdir -p "$destPath"
                    read -p "Are you sure you want to move the directory '$oldname' to '$destDir'? (y/n): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        if [ -d "$destPath/$oldname" ]; then
                            clear
                            cp -r -i "$srcPath/$oldname" "$destDir"
                            rm -r "$srcPath/$oldname"
                            
                        else
                            mv "$srcPath/$oldname" "$destDir"
                            clear
                            echo "*** File '$srcPath/$oldname' moved to '$destPath/$destFile'. ***"
                        fi
                    else
                        clear
                        echo "Directory move cancelled."
                    fi
                else
                    clear
                    echo "Directory '$oldname' does not exist."
                fi
            else
                clear
                echo "Invalid source path: '$srcPath'"
            fi
            
        fi
    }
    
    search_files() {
        local path="$1"
        local name="$2"
        local type="$3"
        local size="$4"
        local date="$5"
        
        
        echo "Searching for files with the following criteria:"
        
        path=${path:-.}
        
        local find_command="find '$path'"
        
        if [ -n "$name" ]; then
            find_command+=" -name '*$name*'"
        fi
        
        if [ -n "$type" ]; then
            find_command+=" -name '*.$type'"
        fi
        
        if [ -n "$size" ]; then
            find_command+=" -size $size"
        fi
        
        if [ -n "$date" ]; then
            find_command+=" -mtime '$date'"
        fi
        
        echo "Executing command: $find_command"
        
        eval $find_command
    }
    
    
    searchOperation(){
        local type=$1
        
        read -e -p "Enter file path (e.g /home/etc , .): " path
        read -e -p "Enter file name (or part of it): " file_name
        read -e -p "Enter file type (e.g., txt, jpg, etc.): " file_type
        read -e -p "Enter file size (e.g., +1M for files larger than 1MB): " file_size
        read -e -p "Enter the modification time (e.g., -7 for files modified in the last 7 days, press Enter to skip): " mod_date
        
        search_files "$path" "$file_name" "$file_type" "$file_size" "$mod_date" "$type"
    }
    
    fileOperations() {
        local operation=$1
        case $operation in
            1) createOperation "F"  ;;
            2) copyOperation "F" ;;
            3) removeOperation "F" ;;
            4) moveOperation "F" ;;
            5) renameOperation "F" ;;
            6) searchOperation "f" ;;
            *) error_handler ;;
        esac
    }
    
    direOperations() {
        local operation=$1
        case $operation in
            1) createOperation "D" ;;
            2) copyOperation "D" ;;
            3) removeOperation "D" ;;
            4) moveOperation "D" ;;
            5) renameOperation "D" ;;
            6) searchOperation "d" ;;
            *) error_handler ;;
        esac
    }
    
    while true; do
        
        echo "Please Select File or Directory"
        echo "F ---> File || D ---> Directory || (-1) ---> Exit"
        
        read -e -p "Enter your choice: " choice
        choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
        
        if [[ "$choice" = "-1" ]]; then
            echo "Exiting..."
            exit
        fi
        
        if [[ "$choice" != "F" && "$choice" != "D" ]]; then
            error_handler
            continue
        fi
        
        clear
        while true; do
            echo "Select Which Operation to Execute"
            echo " 1 ---> Create || 2 ---> Copy   || 3 ---> Delete"
            echo " 4 ---> Move   || 5 ---> Rename || 6 ---> Search"
            echo "(-1) ---> Exit || 0 ---> Back"
            
            read -e -p "Enter your choice: " opt
            
            if [[ "$opt" = "-1" ]]; then
                echo "Exiting..."
                exit
            fi
            
            if [[ "$opt" = "0" ]]; then
                break
            fi
            
            if [[ "$opt" =~ ^[1-7]$ ]]; then
                clear
                if [[ "$choice" = "F" ]]; then
                    fileOperations "$opt"
                    elif [[ "$choice" = "D" ]]; then
                    direOperations "$opt"
                fi
                break
            else
                error_handler
            fi
        done
    done
}