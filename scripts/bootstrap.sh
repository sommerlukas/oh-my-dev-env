#!/bin/zsh

# Placeholder for the repository URL and target directory
REPO_URL="https://github.com/sommerlukas/oh-my-dev-env.git"  # Replace with the actual repository URL
TARGET_DIR="$HOME/.oh-my-dev-env"  # Replace with the desired target directory

# Function to check if a line exists in a file
line_exists() {
  grep -Fxq "$1" "$2"
}

if [ -d "$TARGET_DIR" ]; then
  echo "Error: The directory $TARGET_DIR already exists. Exiting."
  exit 1
fi

# Clone the repository to the target directory
echo "Cloning repository from $REPO_URL to $TARGET_DIR..."
git clone "$REPO_URL" "$TARGET_DIR" || { echo "Error: Failed to clone repository."; exit 1; }

# Path to .zshrc
ZSHRC="$HOME/.zshrc"

# Add FOO_DIR environment variable to .zshrc if it doesn't already exist
OMDE_DIR_LINE='export OMDE_DIR=$HOME/.oh-my-dev-env'
if ! line_exists "$OMDE_DIR_LINE" "$ZSHRC"; then
  echo "Adding FOO_DIR to .zshrc..."
  echo "$OMDE_DIR_LINE" >> "$ZSHRC"
else
  echo "OMDE_DIR is already set in .zshrc."
fi

# Add alias for fode to .zshrc if it doesn't already exist
ALIAS_LINE='omde() { $OMDE_DIR/scripts/main.sh "$@" ;}'
if ! line_exists "$ALIAS_LINE" "$ZSHRC"; then
  echo "Adding alias 'omde' to .zshrc..."
  echo "$ALIAS_LINE" >> "$ZSHRC"
else
  echo "Alias 'fode' already exists in .zshrc."
fi

# Notify the user
echo "Done! Please restart your terminal or run 'source ~/.zshrc' to apply the changes."

