#!/bin/bash

# Check if Xcode Command Line Tools are already installed
if ! xcode-select -p >/dev/null; then
  echo "Xcode Command Line Tools are not installed. Installing..."
  # Install Xcode Command Line Tools
  xcode-select --install
else
  echo "Xcode Command Line Tools are already installed."
fi

# Check if Homebrew is installed
if ! command -v brew >/dev/null; then
  echo "Homebrew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo '# Set PATH, MANPATH, etc., for Homebrew.' >>/Users/jindal/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/jindal/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Check if Git is already installed
if ! command -v git >/dev/null; then
  echo "Git is not installed. Installing..."
  # Install Git using Homebrew
  brew install git

  if [ "$choice" = "y" ]; then
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"

    echo "Git user name and email have been configured."
  elif [ "$choice" = "n" ]; then
    echo "Please re-run the script and enter the correct information."
  else
    echo "Invalid input. Please enter y or n."
  fi
else
  echo "Git is already installed."
fi

echo "Do you want to configure git user name and email? [y/n]: "
read git_config

if [ "$git_config" = "y" ]; then
  echo "Enter your git user name:"
  read git_username

  echo "Enter your git email:"
  read git_email

  echo "Your git user name is: $git_username"
  echo "Your git email is: $git_email"

  read -p "Is the above information correct? [y/n]: " choice

  if [ "$choice" = "y" ]; then
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"

    echo "Git user name and email have been configured."
  elif [ "$choice" = "n" ]; then
    echo "Please re-run the script and enter the correct information."
  else
    echo "Invalid input. Please enter y or n."
  fi
elif [ "$git_config" = "n" ]; then
  echo "Git user name and email configuration skipped."
else
  echo "Invalid input. Please enter y or n."
fi

# Check if nvm is already installed
if ! command -v nvm >/dev/null; then
  echo "nvm is not installed. Installing..."
  # Install nvm using Homebrew
  brew install nvm
  echo "Updating .zshrc file..."
  # Add nvm initialization to .zshrc file
  # Add the nvm path to the .zshrc file
  echo 'export NVM_DIR="$HOME/.nvm"' >>~/.zshrc
  echo '[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" # This loads nvm' >>~/.zshrc
  echo '[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion' >>~/.zshrc
  # Reload the .zshrc file
  source ~/.zshrc
else
  echo "nvm is already installed."
fi

echo "nvm has been installed and exported to the .zshrc file."

# Check if gh is already installed
if ! command -v gh >/dev/null; then
  echo "gh is not installed. Installing..."
  # Install gh using Homebrew
  brew install gh
  echo "gh has been installed."
  # Login to GitHub
  echo "Logging in to GitHub..."
  gh auth login
  echo "You are now logged in to GitHub."
else
  echo "gh is already installed."
fi

source ./install_shell_config.sh
install_shell_config

# File containing the list of applications to be downloaded
app_list="./installed_apps.txt"

if [ ! -f "$app_list" ]; then
  echo "File $app_list does not exist. Exiting the script."
  echo "Extract list of apps from old mac and save in installed_apps.txt in project root directory"
  exit 1
else
  echo "File $app_list exists. Continuing with the script."
fi

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
  if brew cask info "$app" >/dev/null; then
    if [ "$response" = "s" ] || [ "$response" = "y" ]; then
      echo "Downloading $app..."
      brew cask install "$app" 2>>$err_log
    elif [ "$response" = "n" ]; then
      echo "Skipping $app..."
    else
      # Prompt user for confirmation before downloading
      read -p "Download $app? (y/n/s/yall/nall) " response

      # Check user response and download or skip application
      if [ "$response" = "y" ]; then
        echo "Downloading $app..."
        brew cask install "$app" 2>>$err_log
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
    echo "$app" >>$uninstalled_file
  fi
done <"$app_list"

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
  echo "All applications were installed successfully"
fi
