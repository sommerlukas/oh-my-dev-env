#!/bin/zsh

while getopts ":hs" option; do
	case $option in
		h) # Print help
			echo "Run this script with the '-u' option to install in user directory only"
			echo "Run this script with the '-s' option to install through system package manager as much as possible (requires sudo)"
			exit;;
		s) # Run in system mode
			echo "Installing in system mode"
			system_mode=1;;
		\?) # Unknown option
			echo "Invalid option, use '-h' to print help"
			exit 1;;
	esac
done

echo "Starting tool installation..."

cur_dir=`pwd`

# Install nvim itself if not present on the machine
nvim_exe=`which nvim`

if [[ -x "$nvim_exe" ]]; then
	printf "Using 'nvim' executable %s\n" "$nvim_exe"
else
	printf "'nvim' not found, installing...\n"
	nvim_tmp_dir=`mktemp -d`
	cd "$nvim_tmp_dir"
	wget -q https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
	tar xzf nvim-linux-x86_64.tar.gz
  mkdir -p $HOME/bin
	mv nvim-linux-x86_64 $HOME/bin/nvim-linux-x86_64
	cd "$cur_dir"	
	rm -rf "$nvim_tmp_dir"
	ln -s "$HOME/bin/nvim-linux-x86_64/bin/nvim" "$HOME/bin/nvim"
fi

# Install clangd
clangd_exe=`which clangd`

if [ -x "$clangd_exe" ]; then
	printf "Using 'clangd' executable %s\n" "$clangd_exe"
else
	echo "'clangd' not found, installing..."
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install -y clangd; then
			echo "Failed to install clangd from system package manager, please install manually"
		fi
	else
		clangd_tmp_dir=`mktemp -d`
		cd "$clangd_tmp_dir"
		wget -q https://github.com/clangd/clangd/releases/download/19.1.2/clangd-linux-19.1.2.zip	
		unzip clangd-linux-19.1.2.zip
    mkdir -p $HOME/bin
		mv clangd_19.1.2 $HOME/bin/clangd_19.1.2
		cd "$cur_dir"	
		rm -rf "$clangd_tmp_dir"
		ln -s "$HOME/bin/clangd_19.1.2/bin/clangd" "$HOME/bin/clangd"
	fi
fi

# Install ripgrep 
ripgrep_exe=`which rg`

if [ -x "$ripgrep_exe" ]; then
	printf "Using 'rg' executable %s\n" "$ripgrep_exe"
else
	echo "'rg' not found, installing..."
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install -y ripgrep; then
			echo "Failed to install ripgrep from system package manager, please install manually"
		fi
	else
		ripgrep_tmp_dir=`mktemp -d`
		cd "$ripgrep_tmp_dir"
		wget -q https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
		tar xzf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
    mkdir -p $HOME/bin
		mv ripgrep-14.1.1-x86_64-unknown-linux-musl $HOME/bin/ripgrep
		cd "$cur_dir"	
		rm -rf "$ripgrep_tmp_dir"
		ln -s "$HOME/bin/ripgrep/rg" "$HOME/bin/rg"
	fi
fi

# Install tmux
tmux_exe=`which tmux`

if [ -x "$tmux_exe" ]; then
	printf "Using 'tmux' executable %s\n" "$tmux_exe"
else
	echo "'rg' not found, installing..."
	if ! sudo apt install -y tmux; then
		echo "Failed to install tmux from system package manager, please install manually"
	fi
fi

# Install nvm and use it to install node and npm.
mkdir -p "$HOME/bin/nvm"
# Set the PROFILE to null to avoid nvm adding paths to the profile.
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | NVM_DIR="$HOME/bin/nvm" bash'
old_path=$PATH
source "$HOME/bin/nvm/nvm.sh"
nvm install 22.13.1

# Install pyright via npm
npm install --prefix "$HOME/bin/npm-packages" -g pyright

ubuntu_version=`lsb_release -r | grep -E -oh "[0-9]+" | head -1`

if [[ ubuntu_version -gt 20 ]]; then
	npm install --prefix "$HOME/bin/npm-packages" -g tree-sitter-cli
fi

# Revert changes made to PATH by nvm to make them permanent
# in the next step.
export PATH=$old_path

add_to_path() {
	local dir=$1
	if [[ ":$PATH:" == *":$HOME/$dir"* ]]; then
        	echo "HOME/$dir already part of PATH"
	else
        	echo "Adding HOME/$dir to PATH"
		echo "export PATH=\$HOME/$dir:\$PATH" >> $HOME/.zshrc
	fi
}

add_to_path "bin"
add_to_path "bin/nvm/versions/node/v22.13.1/bin"
add_to_path "bin/npm-packages/bin"

echo "Finished tool installation, source ~/.zshrc to make tools available"

exit 0
