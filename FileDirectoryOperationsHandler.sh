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
    # elif [[ "$operationType" =~ "D" ]]; then
    # read -e -p "Enter the path where the directory is located (optional): " path
    # read -e -p "Enter the directory name to rename: " oldname
    # read -e -p "Enter the new directory name: " newname
    
    # path=${path:-.}
    
    # if [ -d "$path" ]; then
    #     if [ -d "$path/$oldname" ]; then
    #         read -p "Are you sure you want to rename the directory '$path/$oldname' to '$path/$newname'? (y/n): " confirm
    #         if [[ "$confirm" =~ ^[Yy]$ ]]; then
    #             mv "$path/$oldname" "$path/$newname"
    #             clear
    #             echo "*** Directory '$path/$oldname' renamed to '$path/$newname'. ***"
    #         else
    #             clear
    #             echo "Directory renaming cancelled."
    #         fi
    #     else
    #         clear
    #         echo "Directory '$path/$oldname' does not exist."
    #     fi
    # else
    #     clear
    #     echo "Invalid path: '$path'"
    # fi
    
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
    local tt="$6"
    
    echo "Searching for files with the following criteria:"
    
    path=${path:-.}
    
    local find_command="find '$path' -type '$tt'"
    
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

# fileOperations "$opt"

