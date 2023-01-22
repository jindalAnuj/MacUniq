#!/bin/bash

install_shell_config() {
    read -p "Do you want to configure bash-utils? [y/n]: " choice

    if [ "$choice" = "y" ]; then
        # Create the .zshrc file if it does not exist
        if [ ! -f ~/.zshrc ]; then
            touch ~/.zshrc
        fi

        # Clone the bash-utils repository into the ~/.shell_config directory
        if [ ! -d ~/.shell_config ]; then
            git clone https://github.com/jindalAnuj/bash-utils.git ~/.shell_config
        else
            echo "The ~/.shell_config directory already exists."
        fi

        # Add the command to source all files in the ~/.shell_config directory in the .zshrc file
        echo 'for f in ~/.shell_config/*.sh; do source $f; done' >> ~/.zshrc

        # Reload the .zshrc file
        source ~/.zshrc

        echo "The .zshrc file has been created, the bash-utils repository has been cloned into the ~/.shell_config directory, and the command to source all files in the ~/.shell_config directory has been added to the .zshrc file."
    elif [ "$choice" = "n" ]; then
        echo "Installation terminated."
    else
        echo "Invalid input. Please enter y or n."
        ## Recursion 
        install_shell_config
    fi
}

# In the script that defines the function
export -f install_shell_config