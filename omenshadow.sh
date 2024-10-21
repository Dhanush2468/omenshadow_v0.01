#!/bin/bash

# Clear the terminal before starting
clear

# Function to display ASCII art
display_ascii_art1() {
    echo "                                                                                       "
    echo "                                        :.                                             "
    echo "                                     :=+=-==:                                          "
    echo "                                  :=-.:-++=----:.                                      "
    echo "                               .--:.-+++++++++==-:=                                    "
    echo "                             .-:.-=++++++++++++++#%-                                   "
    echo "                            .::++++++++++++++++++++*+                                  "
    echo "                            :.++++++++++++++++++++++#*                                 "
    echo "                            .:=++++++++++++++++++++++*#                                "
    echo "                          .-.=++++++++++++++++++++++++%=                               "
    echo "                          =.:+++++++++++++++++++++++++#-                               "
    echo "                         ...+%%*++++++++++++++++++++++*=                               "
    echo "                        .:-:#@@@#*+++++++++++++++++++++*                               "
    echo "                        .:=-%%%%%%#*+++++++++++++++++++%                               "
    echo "                        .--*%%%%%%%%%%#*+++++++++++++++%-                              "
    echo "                        ..-%%%%%%%%%%%%%#*+++++++++*+++#%=                             "
    echo "                        .:*%%%%%%%%%%%%#+-:-=++++++**++*@*                             "
    echo "                        -:*%@%%%%%%%%%#=   =*=+++++***++%%=.                           "
    echo "                       :-+#@@@%%%%%%%%%#++*%%*-+++++***+*%#+=.                         "
    echo "                      :=+#@@@@%%%%%%%%%%%%%%%%+-++++*#*++**+++*.                       "
    echo "                   .:-:+*@@%%%#%%%%%%%%%%%%%%%%+=+++*##++++++++#                       "
    echo "                  .:=+**#@@@@@%##%%%%%%%%%%##%%%++++*#*+++++++*#=-----====             "
    echo "                   :=++*%@@@@@@%##%%%%%%###%%%%*=++#%+++++++++++++**###%%:             "
    echo "                   .:*#*+*#@%%@@%###%%###%%%%%*=+#%%*++*+*+++**#%%%%%@@@@:             "
    echo "                   -.-*#%#**##@@@@%####%%#*++*#%%#**###++*#%%%#++-==+%%%@=             "
    echo "               :-: #%**++**####%%@@@%%%*++#%%@%#*###*+*#%%%%+=+**+***++#%*             "
    echo "            .:::=+:*@@@@%#*#*#%%#**%#*+#%@@####%#+*#%%%%#*==+***********##:+           "
    echo "           :.-+****==*%@@@@%%###%%%++#@@###%%#***%%%#*++=-+**********+==++::=.         "
    echo "           -:=+****#*#+%%@@@@@#%%%@%@%##%@%#**###****==***********+==+**++--=#+.       "
    echo "            =.-*******#=%@%%@@%###%%#%%%#***##*****+-+*********+==*%%#***+==*==#=-     "
    echo "             +#=+*******=%#%%%#####%##***********=-=********+==*%%%%#*+==*=+=-#+=*     "
    echo "            :*%@#=******=-*+#%#####*#***#******+=+*********--#%%%%%%+=+**#*#+##**#+    "
    echo "            :+=:+%*+*****=***#######**##*****+=+********+=++%%%%%%%=+##*********+#%    "
    echo "            . =#%%%#=**********####*%%*****+==+*****+==+#%%%%%%%%%=*%%#******##**##.   "
    echo "             .:+#%%%#-+********##*#%#************+=+*%%%%%%%%%%%%%+%%%##****#####%*:   "
    echo "               .-+#%%#=-+*******###***********==+#@@%%%%%%%%@%%%%%%%%###%%%%%%#=-:.    "
    echo "                                                                                       "
    echo "                         GitHub: your-github-link                      "
    echo
}



# Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo "ADB is not installed. Please install it first."
    exit 1
fi

# Check if scrcpy is installed
if ! command -v scrcpy &> /dev/null; then
    echo "scrcpy is not installed. Please install it first."
    exit 1
fi

# Display welcome message
display_ascii_art1

# Array to hold target IPs
declare -a TARGET_IPS

# Function to connect to a device
connect_device() {
    read -p "Enter the target IP address: " TARGET_IP
    adb connect "$TARGET_IP" 2>&1 | tee adb_output.txt
    if grep -q "device '$TARGET_IP' not found" adb_output.txt; then
        echo "The device $TARGET_IP is offline. Please try another IP."
        return 1
    elif grep -q "connected to" adb_output.txt; then
        echo "Connected to $TARGET_IP."
        TARGET_IPS+=("$TARGET_IP")
        return 0
    else
        echo "Failed to connect to $TARGET_IP. Please try again."
        return 1
    fi
}

# Connect to a device before menu
while true; do
    if connect_device; then
        break
    fi
done

# Function to list connected devices
list_connected_devices() {
    echo "Connected devices:"
    adb devices | awk 'NR>1 {print $1}' | while read -r DEVICE; do
        echo "- $DEVICE"
    done
}

# Function to take a screenshot
take_screenshot() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        if adb -s "$TARGET_IP" exec-out screencap -p > "screenshot_${TARGET_IP//./_}_$TIMESTAMP.png"; then
            echo "Screenshot saved as screenshot_${TARGET_IP//./_}_$TIMESTAMP.png"
        else
            echo "Failed to take screenshot on $TARGET_IP."
        fi
    done
}

# Function to access the shell
access_shell() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        echo "Accessing shell on $TARGET_IP..."
        adb -s "$TARGET_IP" shell
    done
}

# Function to display live screen and control the device
display_live_screen() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        echo "Starting live screen display and control on $TARGET_IP..."

        # Set XDG_RUNTIME_DIR to a temporary directory
        export XDG_RUNTIME_DIR=/tmp
        scrcpy -s "$TARGET_IP" --no-audio &  # Add --no-audio option
    done
    wait
}

# Function to download a file from the device
download_file() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        read -p "Enter the path of the file on the device for $TARGET_IP: " DEVICE_PATH
        read -p "Enter the name for the saved file: " LOCAL_FILENAME
        if adb -s "$TARGET_IP" pull "$DEVICE_PATH" "$LOCAL_FILENAME"; then
            echo "File downloaded from $TARGET_IP as $LOCAL_FILENAME."
        else
            echo "Failed to download the file from $TARGET_IP."
        fi
    done
}

# Function to upload a file to the device
upload_file() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        read -p "Enter the local path of the file to upload for $TARGET_IP: " LOCAL_PATH
        read -p "Enter the destination path on the device: " DEVICE_PATH
        if adb -s "$TARGET_IP" push "$LOCAL_PATH" "$DEVICE_PATH"; then
            echo "File uploaded to $TARGET_IP."
        else
            echo "Failed to upload the file to $TARGET_IP."
        fi
    done
}

# Function to uninstall an application
uninstall_app() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        read -p "Enter the package name of the app to uninstall on $TARGET_IP: " PACKAGE_NAME
        if adb -s "$TARGET_IP" uninstall "$PACKAGE_NAME"; then
            echo "Uninstalled $PACKAGE_NAME from $TARGET_IP."
        else
            echo "Failed to uninstall $PACKAGE_NAME from $TARGET_IP."
        fi
    done
}

# Function to install an application
install_app() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        read -p "Enter the local path of the APK to install on $TARGET_IP: " APK_PATH
        if adb -s "$TARGET_IP" install "$APK_PATH"; then
            echo "Installed $APK_PATH on $TARGET_IP."
        else
            echo "Failed to install $APK_PATH on $TARGET_IP."
        fi
    done
}

# Function to send a text message
send_text_message() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        read -p "Enter the message to send to $TARGET_IP: " MESSAGE
        echo "Sending the following message to $TARGET_IP:"
        echo "Message: $MESSAGE"
        echo "Note: This is a simulated action. SMS not actually sent."
        echo
    done
}

# Function to reboot the device
reboot_device() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        echo "Rebooting $TARGET_IP..."
        adb -s "$TARGET_IP" reboot
    done
}

# Function to open files or images on the device
open_files_or_images() {
    echo "Connected devices:"
    for i in "${!TARGET_IPS[@]}"; do
        echo "$((i + 1)). ${TARGET_IPS[i]}"
    done

    read -p "Choose the device number to open files/images: " device_number
    if [[ "$device_number" -gt 0 && "$device_number" -le "${#TARGET_IPS[@]}" ]]; then
        TARGET_IP="${TARGET_IPS[$((device_number - 1))]}"
        read -p "Enter the path of the file/image to open on $TARGET_IP: " FILE_PATH
        if adb -s "$TARGET_IP" shell "am start -a android.intent.action.VIEW -d file://$FILE_PATH"; then
            echo "Opening $FILE_PATH on $TARGET_IP."
        else
            echo "Failed to open $FILE_PATH on $TARGET_IP."
        fi
    else
        echo "Invalid device number."
    fi
}

# Function to list running applications
list_running_apps() {
    for TARGET_IP in "${TARGET_IPS[@]}"; do
        echo "Running applications on $TARGET_IP:"
        adb -s "$TARGET_IP" shell "pm list packages -3" | sed 's/package://g'
    done
}

# Main menu
while true; do
    echo "Choose an option:"
    echo "1. List Connected Devices"
    echo "2. Take Screenshot"
    echo "3. Access Shell"
    echo "4. Display Live Screen (stop with Ctrl+C)"
    echo "5. Download File from Device"
    echo "6. Upload File to Device"
    echo "7. Uninstall Application"
    echo "8. Install Application"
    echo "9. Send Text Message"
    echo "10. Reboot Device"
    echo "11. Open Files or Images on Device"
    echo "12. List Running Applications"
    echo "13. Exit"
    read -p "Enter your choice: " CHOICE

    case "$CHOICE" in
        1)
            list_connected_devices
            ;;
        2)
            take_screenshot
            ;;
        3)
            access_shell
            ;;
        4)
            display_live_screen
            ;;
        5)
            download_file
            ;;
        6)
            upload_file
            ;;
        7)
            uninstall_app
            ;;
        8)
            install_app
            ;;
        9)
            send_text_message
            ;;
        10)
            reboot_device
            ;;
        11)
            open_files_or_images
            ;;
         12)
            list_running_apps
            ;;
        13)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
