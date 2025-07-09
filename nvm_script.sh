#!/bin/bash

# README: Script to check for Node Version Manager (NVM) installation and optionally install a specific version, 
#         or install the latest version if not found.

echo "Checking for Node Version Manager (NVM)..."

# checks terminal for NVM_DIR variable & if it points to an existent directory, if not present moves to install NVM latest version 
if [ -n "$NVM_DIR" ] && [ -d "$NVM_DIR" ]; then 
    echo "NVM directory found: $NVM_DIR"
    # directs terminal to source nvm.sh script
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
        # communicates version of NVM currently installed, prompts user to select alternate version 
        current_install=$(nvm --version)
        echo -e "\nActive: Node Version Manager v$current_install\n"
        read -rp "Select an alternate NVM version to install? (y/n) " response
        # provides list of the most recent 20 published NVM versions on github or exits script 
        if [[ "$response" =~ ^[Yy]$ ]]; then
            versions=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases | \
                        grep '"tag_name":' | \
                        sed -E 's/.*"([^"]+)".*/\1/' | \
                        sort -V)
            echo -e "Available remote NVM versions:\n${versions}"
            while true; do  
                read -rp "Enter the version to install (e.g., v0.40.3): " version
                # validates user input & installs selected version 
                if echo "$versions" | grep -xq "$version"; then
                    if [[ "$version" == "v$current_install" ]]; then
                        echo -e "NVM version $version active & already installed\nNo action taken. Exiting"
                        break
                    else 
                        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" | bash
                        echo -e "\n-------------------------------- \
                            \nSuccessfully installed Node Version Manager $version \
                            \n- reload terminal for use\n"
                        break
                    fi 
                else
                    echo "Version '$version' is not listed."
                fi
            done
        else
            echo -e "Exiting alternate NVM version install.\n"
        fi

    else
        echo "NVM script not found at $NVM_DIR/nvm.sh"
    fi
else
    echo "NVM is not installed or NVM_DIR is not set."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash 
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    echo -e "\nLatest Node Version Manager installed successfully."
fi

