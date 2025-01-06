#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
        echo "Failed to install Homebrew. Exiting."
        exit 1
    fi
fi

# Check if package lists exist
if [ ! -f "brew_packages.txt" ] || [ ! -f "brew_casks.txt" ]; then
    echo "Package list files not found. Generating package lists..."
    brew list --formula > brew_packages.txt
    brew list --cask > brew_casks.txt
    echo "Package lists have been created in brew_packages.txt and brew_casks.txt."
fi

# Start generating the install script
echo "#!/bin/bash" > install_brew_packages.sh
echo "" >> install_brew_packages.sh
echo "# Install packages" >> install_brew_packages.sh
while read p; do
  echo "brew install $p" >> install_brew_packages.sh
done < brew_packages.txt

# Add commands to install casks
echo "" >> install_brew_packages.sh
echo "# Install casks" >> install_brew_packages.sh
while read c; do
  echo "brew install --cask $c" >> install_brew_packages.sh
done < brew_casks.txt

# Make the script executable
chmod +x install_brew_packages.sh
echo "Installation script 'install_brew_packages.sh' has been created."

