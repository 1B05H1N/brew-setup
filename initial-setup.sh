#!/bin/bash

# Script to set up Homebrew and generate installation scripts
# This script will:
# 1. Check and install Homebrew if needed
# 2. Generate or update package lists
# 3. Create an installation script

set -e  # Exit on error

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || handle_error "Failed to install Homebrew"
    
    # Add Homebrew to PATH if needed (for Apple Silicon Macs)
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Backup existing package lists if they exist
if [ -f "brew_packages.txt" ]; then
    cp brew_packages.txt brew_packages.txt.backup
    echo "Backed up existing brew_packages.txt"
fi
if [ -f "brew_casks.txt" ]; then
    cp brew_casks.txt brew_casks.txt.backup
    echo "Backed up existing brew_casks.txt"
fi

# Generate package lists
echo "Generating package lists..."
brew list --formula > brew_packages.txt || handle_error "Failed to generate brew_packages.txt"
brew list --cask > brew_casks.txt || handle_error "Failed to generate brew_casks.txt"

# Check if package lists are empty
if [ ! -s "brew_packages.txt" ] && [ ! -s "brew_casks.txt" ]; then
    echo "Warning: No packages found in your Homebrew installation."
    echo "This might be normal if this is a fresh Homebrew installation."
fi

# Start generating the install script
echo "#!/bin/bash" > install_brew_packages.sh
echo "" >> install_brew_packages.sh
echo "# Auto-generated Homebrew installation script" >> install_brew_packages.sh
echo "# Generated on $(date)" >> install_brew_packages.sh
echo "" >> install_brew_packages.sh
echo "set -e  # Exit on error" >> install_brew_packages.sh
echo "" >> install_brew_packages.sh

# Add Homebrew update
echo "# Update Homebrew" >> install_brew_packages.sh
echo "echo 'Updating Homebrew...'" >> install_brew_packages.sh
echo "brew update" >> install_brew_packages.sh
echo "" >> install_brew_packages.sh

# Install packages
echo "# Install packages" >> install_brew_packages.sh
while read -r p; do
    if [ ! -z "$p" ]; then  # Skip empty lines
        echo "echo 'Installing $p...'" >> install_brew_packages.sh
        echo "brew install $p" >> install_brew_packages.sh
    fi
done < brew_packages.txt

# Add commands to install casks
echo "" >> install_brew_packages.sh
echo "# Install casks" >> install_brew_packages.sh
while read -r c; do
    if [ ! -z "$c" ]; then  # Skip empty lines
        echo "echo 'Installing cask $c...'" >> install_brew_packages.sh
        echo "brew install --cask $c" >> install_brew_packages.sh
    fi
done < brew_casks.txt

# Add cleanup commands
echo "" >> install_brew_packages.sh
echo "# Cleanup" >> install_brew_packages.sh
echo "echo 'Cleaning up...'" >> install_brew_packages.sh
echo "brew cleanup" >> install_brew_packages.sh

# Make the script executable
chmod +x install_brew_packages.sh

echo "Installation script 'install_brew_packages.sh' has been created."
echo "You can now run './install_brew_packages.sh' to install all packages."

