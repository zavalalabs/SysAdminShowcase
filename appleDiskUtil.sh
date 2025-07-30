#!/bin/bash
#What data do we actually need. 
#Toal space and Toatl free space of the instaleld disk, need to exclude any external drives
#This example shows my revisions and a revision by another Systems Administrator
# Function to check the size of each user's home directory
check_home_directory_size() {
    # Print a header
    printf "\n%-15s %-15s\n" "Username" "Size (GB)"
    printf "%-15s %-15s\n" "--------" "--------"

    # Iterate over each user's home directory
    for user_directory in /Users/*; do
        # Get the username from the directory path
        username=$(basename "$user_directory")

        # Get the folder size in kilobytes
        size=$(du -sk "$user_directory" | awk '{print $1}')

        # Convert the size to GBs
        size_in_gb=$(echo "scale=2; $size / 1024 / 1024" | bc)

        # Print the username and folder size in GBs in a formatted way
        printf "%-15s %-15s\n" "$username" "$size_in_gb"
    done
    echo ""
}

# Function to check the free space vs total space of each APFS container
check_disk_space() {
    # Get the list of all internal volumes
    volumes=$(df | awk '/\/dev\/disk/ {print $1}')

    # Print a header
    printf "\n%-40s %-15s %-15s %-10s\n" "Volume" "Free Space" "Total Space" "% Free"
    printf "%-40s %-15s %-15s %-10s\n" "------" "----------" "-----------" "------"

    # Iterate over each volume
    for volume in $volumes; do
        # Get the volume name
        volume_name=$(diskutil info "$volume" | awk -F: '/Volume Name/ {print $2}' | xargs)

        # Skip volumes without a file system or Time Machine volumes
        if [ "$volume_name" = "Not applicable (no file system)" ] || [[ "$volume_name" == com.apple.TimeMachine* ]]; then
            continue
        fi

        # Get the free and total space in human-readable format (GB)
        volume_info=$(df -h | grep "$volume")
        free_space=$(echo "$volume_info" | awk '{print $4}')
        total_space=$(echo "$volume_info" | awk '{print $2}')

        # Calculate the percentage of free space
        free_space_in_bytes=$(df | grep "$volume" | awk '{print $4}' | tr -d 'G')
        total_space_in_bytes=$(df | grep "$volume" | awk '{print $2}' | tr -d 'G')
        percent_free=$(echo "scale=2; $free_space_in_bytes / $total_space_in_bytes * 100" | bc)

        # Print the volume name, free space, total space, and percentage of free space in a formatted way
        printf "%-40s %-15s %-15s %-10s\n" "$volume_name" "$free_space" "$total_space" "$percent_free"
    done
    echo ""
}

# Call the function to check the size of each user's home directory
check_home_directory_size
check_disk_space
