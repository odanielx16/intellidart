#!/bin/bash

echo "Starting initialization script..."

# Set Wi-Fi Country Code
echo "Enter WLAN Country: "
read wifi_country
echo "Setting Wi-Fi country code to $wifi_country..."
sudo tee /etc/wpa_supplicant/wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$wifi_country
EOF
sudo systemctl restart wpa_supplicant
echo "Wi-Fi country code set."

# Update package list and install Apache2
echo "Updating package list..."
sudo apt-get update
sudo apt-get install -y expect
echo "Installing Apache2..."
sudo apt-get install -y apache2
echo "Apache2 installation complete."

# Enable Apache2 to start on boot
echo "Enabling Apache2 to start on boot..."
sudo systemctl enable apache2
echo "Apache2 enabled to start on boot."

# Start Apache2 service
echo "Starting Apache2 service..."
sudo systemctl start apache2
echo "Apache2 service started."

# Download the AccessPopup tarball
echo "Downloading AccessPopup tarball..."
wget -O AccessPopup.tar.gz "https://www.raspberryconnect.com/images/scripts/AccessPopup.tar.gz"
echo "Download complete."

# Extract the tarball
echo "Extracting AccessPopup tarball..."
sudo tar -xvzf ./AccessPopup.tar.gz
echo "Extraction complete."

# Navigate to the AccessPopup directory
cd AccessPopup
echo "Navigated to AccessPopup directory."

# Create an expect script to automate the installation
echo "Creating expect script for automated installation..."
cat << 'EOF' > install_expect.sh
#!/usr/bin/expect -f
set timeout -1
spawn sudo ./installconfig.sh
expect "Select an Option:"
send "1\r"
expect "Press any key to continue"
send "\r"
expect "Select an Option:"
send "2\r"
expect "Enter the new SSID"
send "dartcam\r"
expect "Enter the new Password"
send "getcamera\r"
expect "Press any key to continue"
send "\r"
expect eof
EOF
echo "Expect script created."

# Make the expect script executable
echo "Making expect script executable..."
sudo chmod +x install_expect.sh
echo "Expect script is now executable."

# Run the expect script
echo "Running expect script..."
sudo ./install_expect.sh
echo "Expect script execution complete."

# Clean up by removing the tarball, AccessPopup directory, and expect script
echo "Cleaning up installation files..."
rm install_expect.sh
cd ..
rm AccessPopup.tar.gz
rm -r AccessPopup
echo "Cleanup complete."

# Remove this script to prevent it from running on subsequent boots
echo "Removing firstboot.sh to prevent re-execution..."
rm -f firstboot.sh
echo "firstboot.sh removed."

# Reboot the system
echo "Rebooting system..."
sudo reboot
