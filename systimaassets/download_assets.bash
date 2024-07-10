#!/bin/bash

# Download or update Systima assets from GitHub
downloadAssets() {
    # App to update
    repo="$1"
    echo "Downloading $repo..."
    localDir="/Library/Application Support/Systima/$repo"
    # Set the GitHub repository URL and the local directory path
    github="https://github.com/Systima-Australia/$repo.git"

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
    [[ ! -d "$localDir" ]] && { # Download Assets
        mkdir -p "$localDir"
        git clone "$github" "$localDir"
    } || { # Update Assets
        cd "$localDir" || exit
        git pull
    }

    # Set permissions for the local directory
    sudo chown -R root:wheel "$localDir"
    sudo chmod -R a+rx "$localDir"
}
