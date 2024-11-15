#!/bin/bash
echo -e "\n    ----download_assets START"

installXcodeCLT() {
    # MARK: ----------------- Install XCode CLT -----------------
    # Install Xcode Command Line Tools if not installed
    xcodePath="/Library/Developer/CommandLineTools"
    echo "Checking Xcode CLT install status and version..."
    xcode-select -p && {
        xcodeInstalledVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version" | awk '{print $2}' | cut -d '.' -f 1,2 | sort -V | tail -n1)
        xcodeInstalledVersion="Command Line Tools for Xcode-${xcodeInstalledVersion}"
        echo -e "Current Xcode CLT version:\n${xcodeInstalledVersion}"
    } || {
        xcodeInstalledVersion="Not Installed"
        echo "Xcode Command Line Tools not installed."
    }

    # Command to install Xcode CLT
    sudo touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    xcodeVersion="$(softwareupdate -l | grep -B 1 "Command Line Tools" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)"
    [[ "${xcodeVersion}" != *"${xcodeInstalledVersion}"* ]] && {
        echo -e "Installing Xcode Command Line Tools version:\n${xcodeVersion}"
        sudo softwareupdate -i --verbose "${xcodeVersion}"

        echo "Waiting for Xcode Command Line Tools installation to complete..."
        updateCheck=$(pgrep -x "softwareupdate")
        while [[ "$updateCheck" != "" ]]; do
            sleep 10
            updateCheck=$(pgrep -x "softwareupdate")
        done
        xcode-select -s "${xcodePath}"
        echo "Xcode Command Line Tools installation complete"
    } || echo "Xcode Command Line Tools is up to date."
    sudo rm -vf "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

    # Set Xcode CLT path if not set, or incorrectly set to App path
    [[ $(xcode-select -p) != "${xcodePath}" ]] && {
        echo "Setting XCode CLT path to ${xcodePath}"
        xcode-select -s "${xcodePath}"
    }
}

git -v > /dev/null 2>&1 || {
    echo "Git not detected, checking xcode CLT..."
    installXcodeCLT
}

# ----------------- Download or update Systima assets from GitHub -----------------
downloadAssets() {
    # App to update
    gitRepo="${1}"
    localDir="/Library/Application Support/Systima/${gitRepo}"

    # Download or update assets
    echo -e "\n    downloading ${gitRepo}"
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

    echo -e "\n    ----download_assets END"
}