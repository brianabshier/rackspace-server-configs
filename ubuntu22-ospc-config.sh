#!/bin/bash
# v1.0

# Prompt the user for input
read -p "Please enter your Rackspace Account USER_NAME: " USER_NAME
read -p "Please enter your Rackspace Account's API_KEY: " API_KEY
read -p "Please enter your Server's REGION: " REGION

# Define a function to check the last command status and exit on failure
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Command failed. Exiting."
        exit 1
    fi
}

# Step 1: Download the xe-guest-utilities
wget http://archive.ubuntu.com/ubuntu/pool/main/x/xe-guest-utilities/xe-guest-utilities_7.10.0-0ubuntu1_amd64.deb
check_status

# Step 2: Install xe-guest-utilities
sudo dpkg -i xe-guest-utilities_7.10.0-0ubuntu1_amd64.deb
check_status

# Step 3: Set xe-daemon to start on boot
sudo systemctl enable xe-daemon
check_status

# Step 4: Install xenstore-utils
sudo apt-get update
check_status
sudo apt-get install -y xenstore-utils
check_status

# Step 5: Install nova-agent
sudo curl novaagent.myconfig.info | sudo bash
check_status

# Step 6: Start nova-agent
sudo service nova-agent start
check_status

# Step 7: Set nova-agent to start on boot
sudo systemctl enable nova-agent
check_status

# Install and Configure the Rackspace Monitoring Agent

# Step 1: Create a sources.list file for the Monitoring Agent
echo "deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-22.04-x86_64 cloudmonitoring main" | sudo tee /etc/apt/sources.list.d/rackspace-monitoring-agent.list
check_status

# Step 2: Add a signing key for the apt repository
curl https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
check_status

# Step 3: Update apt-get
sudo apt-get update
check_status

# Step 4: Install the agent
sudo apt-get install -y rackspace-monitoring-agent
check_status

# Step 5: Configure the agent
sudo rackspace-monitoring-agent --setup --username $USER_NAME --apikey $API_KEY
check_status

# Step 6: Start the agent
sudo service rackspace-monitoring-agent start
check_status

# Step 7: Ensure the agent started
sudo service rackspace-monitoring-agent status
check_status

# Step 8: Set the agent to start automatically
sudo systemctl enable rackspace-monitoring-agent
check_status

# Install and Configure Driveclient

# Step 1: Install bzip2 and nscd
sudo apt install -y bzip2 nscd
check_status

# Step 2: Download the driveclient updater
wget https://agentrepo.drivesrvr.com/updater/cloudbackup-updater-latest.tar.bz2
check_status

# Step 3: Extract the file
tar -xvjf cloudbackup-updater-latest.tar.bz2
check_status

# Step 4: Change into the directory (note the version may change)
cd cloudbackup-updater-2.9.010598/
check_status

# Step 5: Run the updater and pass the registration values
sudo ./cloudbackup-updater --configure --user $USER_NAME --apikey $API_KEY --flavor raxcloudserver --datacenter $REGION --apihost api.$REGION.cbu.rackspace.net
check_status

# Step 6: Set the agent to start on boot
sudo systemctl enable driveclient
check_status

# Report success
echo "All commands executed successfully."
