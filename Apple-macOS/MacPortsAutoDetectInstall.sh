#!/bin/bash

# This is a cleaned up and sanatized version of my original scrypt for showcase & sharing purposes.
# Originally Developed for my support of scientific research users. 
# TThis script's goal was to make it so a apple systems administrator didn't have to use composer to build
# out a custom installer each time a new macos version was release. This script as of 10/30/2025 now has some
# automation to upgrade the github urls from teh macports procject to the latest version. This was done
# to reduce the issue of certificate revocation and legacy applications not being supported. 

# Function to check OS version and store it
check_os_version() {
    osVersion=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
    echo "Detected OS version: $osVersion"
    if (( $(echo "$osVersion < 13" | bc -l) )); then
        echo "Version not supported by script"
        exit 1
    fi
}
# Functio# Function to check if MacPorts is installed
check_macports_installed() {
    if [ -f "/opt/local/bin/port" ]; then
        echo "MacPorts is already installed"
        return 0
    else
        echo "MacPorts is not installed"
        return 1
    fi
}
# Function to backup MacPorts with a jamf policy since the design is for use with jamf Pro
backup_macports() {
    echo "Backing up MacPorts with Jamf policy"
    jamf policy -event <YOUR_BACKUP_EVENT_NAME>
}

# Function to install MacPorts
install_macports() {
    # Define the MacPorts URL based on the OS version
    if [[ "$osVersion" == 14* ]]; then
        macPortsURL="https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-14-Sonoma.pkg"
    elif [[ "$osVersion" == 13* ]]; then
        macPortsURL="https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-13-Ventura.pkg"
    elif [[ "$osVersion" == 15* ]]; then
        macPortsURL="https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-15-Sequoia.pkg"
    elif [[ "$osVersion" == 26* ]]; then
        macPortsURL="https://github.com/macports/macports-base/releases/download/v2.11.6/MacPorts-2.11.6-26-Tahoe.pkg"
    else
        echo "Unsupported macOS version"
        exit 1
    fi
 
    # Define variables
    installerPath="/Library/Application Support/JAMF/<YOUR_INSTALLER_PATH>"
    restoreScriptURL="https://svn.macports.org/repository/macports/contrib/restore_ports/restore_ports.tcl"

    # Ensure the installer path exists
    if [ ! -d "$installerPath" ]; then
        mkdir -p "$installerPath"
    fi

    # Check for backup file
    if [ -f "$installerPath/myports.txt" ]; then
        echo "Backup file found"
        # leave myports as the name as this follows legacy macports recomendatiosn for restore tcl script
        restorePorts=true
    elif [ -f "/Users/$(ls -l /dev/console | awk '{print $3}')/Desktop/myports.txt" ]; then
        cp "/Users/$(ls -l /dev/console | awk '{print $3}')/Desktop/myports.txt" "$installerPath/myports.txt"
        echo "Backup file copied from console user's desktop"
        # this is important becase, when files are stored in the jamf folder, standard user accounts are not allowed to access typically. if you change the location of the installer, this will cause even further lockout of the file
        restorePorts=true
    else
        echo "No backup file found. Assuming a new setup and skipping restoration."
        restorePorts=false
    fi

    # Download and install Command Line Tools for Xcode
    # Xcode CLT installation is needed formacports to work, you dont have to do this wiht jamf policy so this is optional.
    # you can do this how ever you want, but it is required for macports to work. Maybe use the ideas from workbrew
    jamf policy -event <YOUR_CLT_INSTALL_EVENT_NAME>

    # Download and install MacPorts
    curl -L -o "$installerPath/MacPorts.pkg" "$macPortsURL"
    installer -pkg "$installerPath/MacPorts.pkg" -target /

    # Download the restore_ports script
    curl -L -o "$installerPath/restore_ports.tcl" "$restoreScriptURL"
    chmod +x "$installerPath/restore_ports.tcl"

    # Restore ports if the backup file exists
    if [ "$restorePorts" = true ]; then
        echo "Restoring ports from backup file"
        /usr/bin/tclsh "$installerPath/restore_ports.tcl" "$installerPath/myports.txt"
    else
        echo "Skipping restoration as no backup file was found."
    fi
}