#!/bin/bash

# MARK: ----------------- Install XCode CLT -----------------

# Install Xcode Command Line Tools if not installed
xcodePath="/Library/Developer/CommandLineTools"
xcodeVersion="$(softwareupdate -l | grep -B 1 "Command Line Tools" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)"

# Command to install Xcode CLT
echo "Checking Xcode CLT..."
[[ "${xcodeVersion}" == *"No new software available."* ]] && {
    echo "Installing Xcode Command Line Tools version: ${xcodeVersion}"
    touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo softwareupdate -i --verbose "${xcodeVersion}"
    sudo rm -vf "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    xcode-select -s "${xcodePath}"
}

# Set Xcode CLT path if not set, or incorrectly set to App path
[[ $(xcode-select -p) != "${xcodePath}" ]] && {
    echo "Setting XCode CLT path to ${xcodePath}"
    xcode-select -s "${xcodePath}"
}

# ----------------- Download or update Systima assets from GitHub -----------------
downloadAssets() {
    # App to update
    gitRepo="${1}"
    localDir="/Library/Application Support/Systima/${gitRepo}"

    # Download or update assets
    echo -e "\n    ----${gitRepo} START"
    # Check if Git repo files exist
    [[ ! -d "${localDir}/.git" ]] && {
        [[ ! -d "${localDir}" ]] && echo "Creating ${gitRepo} folder" && mkdir -p "${localDir}" # If the folder does not exist, make it
        echo "    Cloning ${gitRepo} to ${localDir}"
        git clone "https://github.com/Systima-Australia/${gitRepo}" "${localDir}"
    } || {
        echo "    Checking ${gitRepo} for updates"
        git -C "${localDir}" fetch origin main && git -C "${localDir}" reset --hard origin/main # Fetch the latest changes from the remote and reset the local files to match the remote repository state
    }

    # Set permissions for the local directory
    sudo chown -R root:wheel "${localDir}"
    sudo chmod -R 755 "${localDir}"
    echo -e "    ----${gitRepo} END\n"
}
