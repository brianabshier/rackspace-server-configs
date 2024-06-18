#!/bin/bash

# Define URLs for the different OS bash scripts
UBUNTU_URL="https://e3b66e3782434de948de-87d14e20088081e6aafb761c20cacd23.ssl.cf5.rackcdn.com/ubuntu22-ospc-config.sh"
DEBIAN_URL="https://e3b66e3782434de948de-87d14e20088081e6aafb761c20cacd23.ssl.cf5.rackcdn.com/debian12-ospc-config.sh"
ALMA_URL="https://e3b66e3782434de948de-87d14e20088081e6aafb761c20cacd23.ssl.cf5.rackcdn.com/alma9-ospc-config.sh"
ROCKY_URL="https://e3b66e3782434de948de-87d14e20088081e6aafb761c20cacd23.ssl.cf5.rackcdn.com/rocky9-ospc-config.sh"

# Function to check if wget is installed, and install it if not
ensure_wget_installed() {
    if ! command -v wget &> /dev/null; then
        echo "wget not found. Installing wget..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y wget
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y wget
        else
            echo "Error: Package manager not supported. Please install wget manually."
            exit 1
        fi
    fi
}

# Function to download and execute the script
download_and_execute() {
    local url=$1
    local script_name=$(basename $url)
    
    echo "Downloading script from $url..."
    wget -O $script_name $url
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download script from $url"
        exit 1
    fi

    echo "Making script executable..."
    chmod +x $script_name

    echo "Executing the script..."
    ./$script_name
}

# Ensure wget is installed
ensure_wget_installed

# Prompt the user to select their OS
echo "Please select your operating system:"
echo "1) Ubuntu 22.04"
echo "2) Debian 12"
echo "3) Alma9"
echo "4) Rocky9"
read -p "Enter the number corresponding to your operating system: " os_choice

# Execute the appropriate script based on user input
case $os_choice in
    1)
        download_and_execute $UBUNTU_URL
        ;;
    2)
        download_and_execute $DEBIAN_URL
        ;;
    3)
        download_and_execute $ALMA_URL
        ;;
    4)
        download_and_execute $ROCKY_URL
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

echo "Script executed successfully."
