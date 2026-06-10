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
TREE_SITTER_VERSION="0.24.7"
DIRENV_VERSION="2.37.1"

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

install_tree_sitter() {
	tree_sitter_tmp_dir=`mktemp -d`
	cd "$tree_sitter_tmp_dir"
	wget -q "https://github.com/tree-sitter/tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz"
	gunzip tree-sitter-linux-x64.gz
	chmod +x tree-sitter-linux-x64
	mkdir -p $HOME/bin
	mv tree-sitter-linux-x64 "$HOME/bin/tree-sitter"
	cd "$cur_dir"
	rm -rf "$tree_sitter_tmp_dir"
}

install_direnv() {
	direnv_tmp_dir=`mktemp -d`
	cd "$direnv_tmp_dir"
	wget -q "https://github.com/direnv/direnv/releases/download/v$DIRENV_VERSION/direnv.linux-amd64"
	chmod +x direnv.linux-amd64
	mkdir -p $HOME/bin
	mv direnv.linux-amd64 "$HOME/bin/direnv"
	cd "$cur_dir"
	rm -rf "$direnv_tmp_dir"
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

# Install tree-sitter
tree_sitter_exe=`which tree-sitter`

if [ -x "$tree_sitter_exe" ]; then
	tree_sitter_installed_version=`get_tool_version "$tree_sitter_exe"`
	if version_lt "$tree_sitter_installed_version" "$TREE_SITTER_VERSION"; then
		printf "'tree-sitter' version %s is older than %s, installing...\n" "$tree_sitter_installed_version" "$TREE_SITTER_VERSION"
		install_tree_sitter
	else
		printf "Using 'tree-sitter' executable %s, version %s\n" "$tree_sitter_exe" "$tree_sitter_installed_version"
	fi
else
	echo "'tree-sitter' not found, installing..."
	install_tree_sitter
fi

# Install direnv
direnv_exe=`which direnv`

if [ -x "$direnv_exe" ]; then
	printf "Using 'direnv' executable %s\n" "$direnv_exe"
else
	echo "'direnv' not found, installing..."
	install_direnv
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

echo "Finished tool installation, source ~/.zshrc to make tools available"

exit 0
