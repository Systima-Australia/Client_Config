#!/bin/bash

# Download or update Systima assets from GitHub
downloadAssets() {
    # App to update
    gitRepo="${1}"
    localDir="/Library/Application Support/Systima/${gitRepo}"

    # Install Xcode Command Line Tools if not installed
    installxcode() {
        # Display swiftDialog Notification
        /usr/local/bin/dialog \
        --notification \
        --title "Systima Tools are downloading..." \
        --message "Some Self Service tasks may be paused until this is complete"

        # Install Xcode Command Line Tools
        echo "Installing Xcode Command Line Tools"
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        softwareupdate -l | grep "Label: Command Line Tools" | sed -e 's/^.*Label: //' -e 's/^ *//' | tr -d '\n' | xargs echo | sudo -n -S softwareupdate -i -a
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    }
    [[ ! $(xcode-select -p) ]] && installxcode

    # Download or update assets
    echo -e "\n    -------${gitRepo} START"
    # Check if Git repo files exist
    [[ ! -d "${localDir}/.git" ]] && {
        [[ ! -d "${localDir}" ]] && echo "Creating ${gitRepo} folder"; mkdir -p "${localDir}" # If the folder does not exist, make it
        echo "Cloning ${gitRepo} to ${localDir}"
        git clone "https://github.com/Systima-Australia/${gitRepo}" "${localDir}"
    } || { # Update Assets
        echo "Checking ${gitRepo} for updates"
        git -C "${localDir}" fetch
    }

    # Set permissions for the local directory
    sudo chown -R root:wheel "${localDir}"
    sudo chmod -R 755 "${localDir}"
    echo -e "    -------${gitRepo} END\n"
}
