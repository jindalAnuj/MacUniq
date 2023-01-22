#!/bin/bash

# File to save the list of applications
app_list="./installed_apps.txt"

# Create file to save the list of applications
touch $app_list

# Extract the list of applications
ls /Applications >> $app_list
ls $HOME/Applications >> $app_list

#Removing duplicate entries
sort $app_list | uniq > temp_file
mv temp_file $app_list

# Print the list of applications
echo "The following applications are currently installed on your old Mac:"
cat $app_list
