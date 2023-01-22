#!/bin/bash

# File to save the list of applications
app_list="./installed_apps.txt"

# Create file to save the list of applications
touch $app_list

# Prompt user to include system applications
read -p "Include system applications in the list? (y/n) " include_system_apps

if [ "$include_system_apps" = "y" ]; then
  # Extract the list of applications
  ls /Applications > $app_list
else
  # Extract the list of applications and filter out system apps
  ls /Applications | grep -v "\.app" | grep -v "\.localized" > $app_list
fi

# Print the list of applications
echo "The following applications are currently installed on your old Mac:"
cat $app_list
