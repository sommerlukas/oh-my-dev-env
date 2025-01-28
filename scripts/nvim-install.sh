#!/bin/sh

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

echo "Starting bootstrap..."

cur_dir=`pwd`

# Install nvim itself if not present on the machine
nvim_exe=`which nvim`

if [ -x "$nvim_exe" ]; then
	printf "Using 'nvim' executable %s\n" "$nvim_exe"
else
	printf "'nvim' not found, installing...\n"
	nvim_tmp_dir=`mktemp -d`
	cd "$nvim_tmp_dir"
	wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	tar xzf nvim-linux64.tar.gz
	mv nvim-linux64 $HOME/bin/nvim-linux64
	cd "$cur_dir"	
	rm -rf "$nvim_tmp_dir"
	ln -s "$HOME/bin/nvim-linux64/bin/nvim" "$HOME/bin/nvim"
fi

# Install clangd
clangd_exe=`which clangd`

if [ -x "$clangd_exe" ]; then
	printf "Using 'clangd' executable %s\n" "$clangd_exe"
else
	echo "'clangd' not found, installing..."
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install clangd; then
			echo "Failed to install clangd from system package manager, please install manually"
		fi
	else
		clangd_tmp_dir=`mktemp -d`
		cd "$clangd_tmp_dir"
		wget -q https://github.com/clangd/clangd/releases/download/19.1.2/clangd-linux-19.1.2.zip	
		unzip clangd-linux-19.1.2.zip
		mv clangd_19.1.2 $HOME/bin/clangd_19.1.2
		cd "$cur_dir"	
		rm -rf "$clangd_tmp_dir"
		ln -s "$HOME/bin/clangd_19.1.2/bin/clangd" "$HOME/bin/clangd"
	fi
fi

# Install treesitter
treesitter_exe=`which tree-sitter-cli`

if [ -x "$treesitter_exe" ]; then
	printf "Using 'tree-sitter-cli' executable %s\n" "$treesitter_exe"
else
	echo "'tree-sitter-cli' not found, installing..."
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install tree-sitter-cli; then
			echo "Failed to install tree-sitter-cli from system package manager, please install manually"
		fi
	else
		treesitter_tmp_dir=`mktemp -d`
		cd "$treesitter_tmp_dir"
		wget -q https://github.com/tree-sitter/tree-sitter/releases/download/v0.24.7/tree-sitter-linux-x64.gz
		gzip -d -q tree-sitter-linux-x64.gz
		mv tree-sitter-linux-x64 $HOME/bin/tree-sitter-cli
		chmod +x $HOME/bin/tree-sitter-cli
		cd "$cur_dir"	
		rm -rf "$treesitter_tmp_dir"
	fi
fi

# Install ripgrep 
ripgrep_exe=`which rg`

if [ -x "$ripgrep_exe" ]; then
	printf "Using 'rg' executable %s\n" "$ripgrep_exe"
else
	echo "'rg' not found, installing..."
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install ripgrep; then
			echo "Failed to install tree-sitter-cli from system package manager, please install manually"
		fi
	else
		ripgrep_tmp_dir=`mktemp -d`
		cd "$ripgrep_tmp_dir"
		wget -q https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
		tar xzf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
		mv ripgrep-14.1.1-x86_64-unknown-linux-musl $HOME/bin/ripgrep
		cd "$cur_dir"	
		rm -rf "$ripgrep_tmp_dir"
		ln -s "$HOME/bin/ripgrep/rg" "$HOME/bin/rg"
	fi
fi



exit 0
