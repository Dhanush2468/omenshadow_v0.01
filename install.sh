#!/bin/bash

# Function to install ADB
install_adb() {
    echo "Installing ADB..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y android-tools-adb
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install android-platform-tools
    elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin" ]]; then
        echo "For Windows, please install ADB manually from the Android SDK."
        exit 1
    else
        echo "Unsupported OS. Please install ADB manually."
        exit 1
    fi
}

# Function to install Meson and other dependencies
install_dependencies() {
    echo "Installing necessary dependencies..."
    
    # Install basic dependencies
    sudo apt update
    sudo apt install -y meson pkg-config \
                        libavformat-dev libavcodec-dev libavutil-dev libgtk-3-dev \
                        libpulse-dev libsdl2-dev libswresample-dev libavdevice-dev \
                        build-essential git ninja-build cmake libusb-1.0-0-dev
}

# Function to install scrcpy
install_scrcpy() {
    echo "Installing scrcpy..."
    
    # Clone scrcpy repository
    git clone https://github.com/Genymobile/scrcpy
    
    # Enter the scrcpy directory
    cd scrcpy || exit 1  # Exit with error if directory doesn't exist

    # Run the installation script
    ./install_release.sh
    
    # Go back to the original directory
    cd .. || exit 1  # Exit if it fails to return to the previous directory

    # Clean up
    rm -rf scrcpy

    echo "scrcpy installed successfully and exited the directory."
}

# Check for ADB and install if not found
if ! command -v adb &> /dev/null; then
    install_adb
else
    echo "ADB is already installed."
fi

# Install necessary dependencies
install_dependencies

# Check for scrcpy and install if not found
if ! command -v scrcpy &> /dev/null; then
    install_scrcpy
else
    echo "scrcpy is already installed."
fi

echo "All dependencies are installed."
