#!/bin/bash

# Check if Xcode Command Line Tools are already installed
if ! xcode-select -p > /dev/null; then
    echo "Xcode Command Line Tools are not installed. Installing..."
    # Install Xcode Command Line Tools
    xcode-select --install
else
    echo "Xcode Command Line Tools are already installed."
fi



# Check if Homebrew is installed
if ! command -v brew > /dev/null; then
  echo "Homebrew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi


# Check if Git is already installed
if ! command -v git > /dev/null; then
    echo "Git is not installed. Installing..."
    # Install Git using Homebrew
    brew install git
else
    echo "Git is already installed."
fi

# Check if nvm is already installed
if ! command -v nvm > /dev/null; then
  echo "nvm is not installed. Installing..."
  # Install nvm using Homebrew
  brew install nvm
else
  echo "nvm is already installed."
fi

echo "Updating .zshrc file..."
# Add nvm initialization to .zshrc file
# Add the nvm path to the .zshrc file
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" # This loads nvm' >> ~/.zshrc
echo '[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion' >> ~/.zshrc

# Reload the .zshrc file
source ~/.zshrc

echo "nvm has been installed and exported to the .zshrc file."

# Check if gh is already installed
if ! command -v gh > /dev/null; then
  echo "gh is not installed. Installing..."
  # Install gh using Homebrew
  brew install gh
else
  echo "gh is already installed."
fi

echo "gh has been installed."

# Login to GitHub
echo "Logging in to GitHub..."
gh auth login

echo "You are now logged in to GitHub."


# File containing the list of applications to be downloaded
app_list="./installed_apps.txt"

# Initialize variable to track user response
response=""

# Error log file
err_log="./error.log"

# File to save uninstalled apps
uninstalled_file="./uninstalled_apps.txt"

# Create error log file
touch $err_log

# Create uninstalled apps file
touch $uninstalled_file

# Iterate through the array and download each application
while read -r app; do
  # Check if the application is available in cask
  if brew cask info "$app" > /dev/null; then
    if [ "$response" = "s" ] || [ "$response" = "y" ]; then
      echo "Downloading $app..."
      brew cask install "$app" 2>> $err_log
    elif [ "$response" = "n" ]; then
      echo "Skipping $app..."
    else
      # Prompt user for confirmation before downloading
      read -p "Download $app? (y/n/s/yall/nall) " response

      # Check user response and download or skip application
      if [ "$response" = "y" ]; then
        echo "Downloading $app..."
        brew cask install "$app" 2>> $err_log
      elif [ "$response" = "s" ]; then
        echo "Skipping $app..."
      elif [ "$response" = "yall" ]; then
        echo "Downloading all the remaining apps"
        response="y"
      elif [ "$response" = "nall" ]; then
        echo "Skipping all the remaining apps"
        response="n"
      else
        echo "Skipping $app..."
      fi
    fi
  else
    echo "#################################################################" | tee -a $err_log
    echo "$app is not available to install via cask. Skipping..." | tee -a $err_log
    echo "#################################################################" | tee -a $err_log
    echo "$app" >> $uninstalled_file
  fi
done < "$app_list"

echo "All applications have been downloaded."

if [ -s $err_log ]; then
  echo "There were some errors during installation. Please check $err_log for details"
else
  echo "Installation completed successfully"
fi

if [ -s $uninstalled_file ]; then
  echo "Following applications were not installed, please check $uninstalled_file for details"
  cat $uninstalled_file
else