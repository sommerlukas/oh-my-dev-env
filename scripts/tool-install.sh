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

NVIM_VERSION="0.11.5"
CLANGD_VERSION="22.1.0"

get_tool_version() {
	local tool_exe=$1
	"$tool_exe" --version 2>/dev/null | head -1 | grep -E -o "v?[0-9]+(\.[0-9]+)+" | head -1 | sed "s/^v//"
}

version_lt() {
	local current_version=$1
	local target_version=$2

	if [[ -z "$current_version" ]]; then
		return 0
	fi

	[[ "$current_version" != "$target_version" ]] && [[ "$(printf "%s\n%s\n" "$current_version" "$target_version" | sort -V | head -1)" == "$current_version" ]]
}

install_nvim() {
	nvim_tmp_dir=`mktemp -d`
	cd "$nvim_tmp_dir"
	wget -q "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz"
	tar xzf nvim-linux-x86_64.tar.gz
	mkdir -p $HOME/bin
	rm -rf "$HOME/bin/nvim-linux-x86_64"
	mv nvim-linux-x86_64 $HOME/bin/nvim-linux-x86_64
	cd "$cur_dir"
	rm -rf "$nvim_tmp_dir"
	ln -sfn "$HOME/bin/nvim-linux-x86_64/bin/nvim" "$HOME/bin/nvim"
}

install_clangd() {
	if [ ! -z "$system_mode" ]; then
		if ! sudo apt install -y clangd; then
			echo "Failed to install clangd from system package manager, please install manually"
		fi
	else
		clangd_tmp_dir=`mktemp -d`
		cd "$clangd_tmp_dir"
		wget -q "https://github.com/clangd/clangd/releases/download/$CLANGD_VERSION/clangd-linux-$CLANGD_VERSION.zip"
		unzip "clangd-linux-$CLANGD_VERSION.zip"
		mkdir -p $HOME/bin
		rm -rf "$HOME/bin/clangd_$CLANGD_VERSION"
		mv "clangd_$CLANGD_VERSION" "$HOME/bin/clangd_$CLANGD_VERSION"
		cd "$cur_dir"
		rm -rf "$clangd_tmp_dir"
		ln -sfn "$HOME/bin/clangd_$CLANGD_VERSION/bin/clangd" "$HOME/bin/clangd"
	fi
}

# Install nvim itself if not present on the machine or too old
nvim_exe=`which nvim`

if [[ -x "$nvim_exe" ]]; then
	nvim_installed_version=`get_tool_version "$nvim_exe"`
	if version_lt "$nvim_installed_version" "$NVIM_VERSION"; then
		printf "'nvim' version %s is older than %s, installing...\n" "$nvim_installed_version" "$NVIM_VERSION"
		install_nvim
	else
		printf "Using 'nvim' executable %s, version %s\n" "$nvim_exe" "$nvim_installed_version"
	fi
else
	printf "'nvim' not found, installing...\n"
	install_nvim
fi

# Install clangd
clangd_exe=`which clangd`

if [ -x "$clangd_exe" ]; then
	clangd_installed_version=`get_tool_version "$clangd_exe"`
	if version_lt "$clangd_installed_version" "$CLANGD_VERSION"; then
		printf "'clangd' version %s is older than %s, installing...\n" "$clangd_installed_version" "$CLANGD_VERSION"
		install_clangd
	else
		printf "Using 'clangd' executable %s, version %s\n" "$clangd_exe" "$clangd_installed_version"
	fi
else
	echo "'clangd' not found, installing..."
	install_clangd
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
	echo "'tmux' not found, installing..."
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
