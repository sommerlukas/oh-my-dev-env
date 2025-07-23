#!/bin/zsh

install_config_file() {
  local source_filename=$1
  local target_file=$2
  local source_directory="${OMDE_DIR}"

  # Check if SOURCE_DIR environment variable is set
  if [ -z "$source_directory" ]; then
    echo "Error: OMDE_DIR environment variable is not set."
    return 1
  fi

  # Construct the full path to the source file
  local source_file="$source_directory/config/$source_filename"

  # Check if the source file exists
  if [ ! -f "$source_file" ]; then
    echo "Source file $source_file does not exist."
    return 1
  fi

  local target_directory="$(dirname $target_file)"
  local backup_file="${target_file}.bak"

  # Check if target directory exists, create it if it doesn't
  if [ ! -d "$target_directory" ]; then
    echo "Target directory $target_directory does not exist, creating it."
    mkdir -p "$target_directory"
  fi

  # If file already exists in target directory, create a backup
  if [ -f "$target_file" ]; then
    echo "Backing up existing file to $backup_file."
    mv "$target_file" "$backup_file"
  fi

  # Copy the file to the target directory
  cp "$source_file" "$target_file"
}

# Set XDG config dir if not already set
: "${XDG_CONFIG_HOME:=$HOME/.config}"

install_config_file "tmux.conf" "$HOME/.tmux.conf"
install_config_file "init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
install_config_file "lazy.lua" "$XDG_CONFIG_HOME/nvim/lua/config/lazy.lua"
install_config_file "view.lua" "$XDG_CONFIG_HOME/nvim/lua/plugins/view.lua"
install_config_file "git.lua" "$XDG_CONFIG_HOME/nvim/lua/plugins/git.lua"
install_config_file "files.lua" "$XDG_CONFIG_HOME/nvim/lua/plugins/files.lua"
install_config_file "language.lua" "$XDG_CONFIG_HOME/nvim/lua/plugins/language.lua"
