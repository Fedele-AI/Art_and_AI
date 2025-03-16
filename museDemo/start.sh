#!/bin/bash
# This script starts the Muse LSL stream and then runs the demo script.
# (c) 2025 MUSE_AI Research Group, Georgia Institute of Technology.
# Build: 2025-23-02 for CEE4803/LMC4813

# Check if the OS is Linux or MacOS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # OS specific commands:
    pythonReference="python"
    # Check if the muselsl command is available
    if ! command -v muselsl &> /dev/null; then
        echo "❌ muselsl command not found. Please install the muselsl package."
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # OS specific commands:
    pythonReference="python3"
    # Check if the muselsl command is available
    if ! command -v muselsl &> /dev/null; then
        echo "❌ muselsl command not found. Please install the muselsl package."
        exit 1
    fi
else
    echo "❌ Unsupported OS. Please use Linux or MacOS."
    exit 1
fi

# Function to clean up background processes
cleanup() {
    echo -e "\nCleaning up... Thanks, and Go Jackets! 🐝 "
    kill $muselsl_pid
    wait $muselsl_pid 2>/dev/null
    exit 0
}

# Trap SIGINT and SIGTERM signals to clean up when the script is killed
trap cleanup SIGINT SIGTERM

# Start the muselsl stream command in the background
# Save MAC address to a variable for the user to input

# Print instructions for the user
echo "Welcome to the FEDELE_AI Research Group Brain-Computer-Interface-2-Visualizer (BCI2V) Program."
echo -e "Version: 1.0"
echo -e "Build: 2025-18-02 for CEE4803/LMC4813"
echo ""
echo "Developed @ College of Engineering, Georgia Institute of Technology. Go Jackets! 🐝"
sleep 1
echo ""
echo -e "‼️ \033[31m WARNING: During this program, you may see debugging information and warnings from the Muse LSL stream.\033[0m"
echo "             This is normal and expected behavior. Please report any bugs via an open a issue on GitHub, and attach"
echo "             all relevant logs and information."
echo ""
echo "⚠️ Please ensure that your Muse device is turned on and discoverable."
echo "This program comes with no warranty. Use at your own risk."
sleep 1
echo ""
echo "Looking for Muses... 🔎"
# List all detected Muse devices
devices=$(muselsl list | sed -n 's/.*MAC Address //p')

# Check if no devices were found
if [[ -z "$devices" ]]; then
  echo "❌ No Muses found. Exiting."
  exit 1
fi

# Convert the devices into an array
device_array=($devices)

# Iterate through the devices
for mac in "${device_array[@]}"; do
  read -p "Is this your Muse MAC Address: $mac? (y/n) " confirm
  if [[ "$confirm" == "y" ]]; then
    macAddress=$mac
    echo "MAC Address saved: $macAddress"
    break
  fi
done

# If no confirmation, exit
if [[ -z "$macAddress" ]]; then
  echo "No MAC Address confirmed. Exiting."
  exit 1
fi

# Start muselsl stream with the given address in the background
muselsl stream --address "$macAddress" &
muselsl_pid=$!

# Give muselsl some time to establish the connection
echo "Establishing connection to Muse device..."
sleep 10    # Note: This should force the script to wait until the connection is established.
            # If you have issues with your connection, please increase the sleep time.

# Execute the Python script with the predetermined Python reference
$pythonReference demo.py

# If the python script closes, clean up the muselsl process
cleanup