#!/bin/bash

# Prompt the user for input
read -p "Please enter your USER_NAME: " USER_NAME
read -p "Please enter your API_KEY: " API_KEY
read -p "Please enter your REGION: " REGION

# Define a function to check the last command status and exit on failure
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Command failed. Exiting."
        exit 1
    fi
}

# Step 1: Check network interfaces
nmcli device status
if [ $? -ne 0 ]; then
    nmcli networking on
    check_status
fi

# Step 2: Ensure nova-agent and xe-linux-distribution are running and enabled

# Remove and reinstall xe-guest-utilities if necessary
sudo dnf remove -y xe-guest-utilities
check_status
sudo dnf install -y xe-guest-utilities-latest
check_status

# Start and enable xe-linux-distribution
sudo systemctl start xe-linux-distribution
check_status
sudo systemctl enable xe-linux-distribution
check_status
sudo systemctl status xe-linux-distribution
check_status

# Restart and check nova-agent
sudo systemctl restart nova-agent
check_status
sudo systemctl status nova-agent
check_status

# Install cloud backup driveclient

# Step 1: Add required repo
sudo dnf --nogpgcheck install -y https://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el9.noarch.rpm
check_status

# Step 2: Install LSB headers
sudo dnf --enablerepo=gf install -y redhat-lsb-core
check_status

# Step 3: Test LSB and install wget
lsb_release -a
check_status
sudo yum install -y wget
check_status

# Step 4: Download bzip2 and tar
yum install -y bzip2 nscd
check_status
wget https://agentrepo.drivesrvr.com/updater/cloudbackup-updater-latest.tar.bz2
check_status
tar -xvjf cloudbackup-updater-latest.tar.bz2
check_status

# Step 5: Install driveclient
cd cloudbackup-updater-2.9.010598/
check_status

# Step 6: Register driveclient agent
sudo ./cloudbackup-updater --configure --user $USER_NAME --apikey $API_KEY --datacenter $REGION --flavor raxcloudserver --apihost api.$REGION.cbu.rackspace.net
check_status

# Step 7: Start and enable driveclient service
sudo service driveclient start
sudo systemctl enable driveclient
check_status

# Install rackspace-monitoring-agent

# Step 1: Enable package signing key
curl https://monitoring.api.rackspacecloud.com/pki/agent/rocky-8.asc > /tmp/signing-key.asc
check_status

# Step 2: Import signing key
sudo rpm --import /tmp/signing-key.asc
check_status

# Step 3: Create repo
sudo tee /etc/yum.repos.d/rackspace-cloud-monitoring.repo <<EOL
[rackspace]
name=Rackspace Monitoring
baseurl=https://stable.packages.cloudmonitoring.rackspace.com/rockylinux-8-x86_64/
enabled=1
gpgcheck=1
EOL
check_status

# Step 4: Update repo list
sudo dnf update -y
check_status

# Step 5: Install agent
sudo dnf install -y rackspace-monitoring-agent
check_status

# Step 6: Configure the agent with the Setup program
sudo rackspace-monitoring-agent --setup --username $USER_NAME --apikey $API_KEY
check_status

# Step 7: Start agent
sudo rackspace-monitoring-agent start -D
check_status

# Step 8: Start service
sudo systemctl start rackspace-monitoring-agent
check_status

# Step 9: Enable service
sudo systemctl enable rackspace-monitoring-agent
check_status

# Step 10: Ensure all networks are enabled
nmcli networking on

# Report success
echo "All commands executed successfully. The Backup Agent and Monitoring Agent should now be registered and installed."
