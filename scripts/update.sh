#!/bin/zsh

# Store the current directory
original_dir=$(pwd)

# Check if the OMDE_DIR environment variable is set
if [ -z "$OMDE_DIR" ]; then
  echo "Error: OMDE_DIR environment variable is not set."
  exit 1
fi

# Define the repository URL (replace <URL> with the actual GitHub repository URL)
REPO_URL="https://github.com/sommerlukas/oh-my-dev-env.git"

# Check if OMDE_DIR exists and is a valid git repository
if [ ! -d "$OMDE_DIR" ] || [ ! -d "$OMDE_DIR/.git" ]; then
  echo "Error: $OMDE_DIR is not a valid git repository."
  exit 1
fi

# Change to the repository directory
cd "$OMDE_DIR"

# Function to check if the repository is dirty, on 'main', and has no local commits not in upstream
check_local_repository() {
  # Check if the repository is dirty (has uncommitted changes)
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: Repository is dirty. Please commit or stash your changes first."
    return 1
  fi

  # Check if we are on the 'main' branch
  if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
    echo "Error: You must be on the 'main' branch to perform this operation."
    return 1
  fi

  # Check if the local copy has commits not pushed to the upstream
  local branch_name=$(git rev-parse --abbrev-ref HEAD)
  git fetch "$REPO_URL" || { echo "Error: Failed to fetch updates."; return 1; }

  local remote_name=$(git remote show)

  # Check if the local branch has commits that haven't been pushed to the upstream
  local local_commits=$(git log "$remote_name/$branch_name"..HEAD --oneline)
  if [ -n "$local_commits" ]; then
    echo "Error: Your local copy has commits that haven't been pushed to the upstream."
    return 1
  fi

  return 0  # If all checks pass
}

# Function to update the repository
update_repository() {
  # Pull the latest changes from GitHub
  echo "Repository is clean. Updating..."
  git pull "$REPO_URL" || { echo "Error: Failed to update the repository."; return 1; }

  # Run the config-install.sh script
  if [ -f "$OMDE_DIR/scripts/config-install.sh" ]; then
    echo "Running config-install.sh..."
    $OMDE_DIR/scripts/config-install.sh || { echo "Error: Failed to run config-install.sh."; return 1; }
  else
    echo "Error: config-install.sh script not found."
    return 1
  fi
}

# Function to get the number of commits different between the local and remote branches
get_commit_diff_count() {
  # Fetch the latest updates from the remote repository
  local remote_name=$(git remote show)
  git fetch "$remote_name" || { echo "Error: Failed to fetch updates."; return 1; }

  # Get the number of commits ahead or behind the current local branch
  local branch_name=$(git rev-parse --abbrev-ref HEAD)
  local ahead_commits=$(git rev-list --count HEAD.."$remote_name/$branch_name")

  # Return the total number of commits that differ
  echo $ahead_commits
}

# Handle "check" and "update" commands
case "$1" in
  update)
    # Check the repository before attempting the update
    if check_local_repository; then
      # If checks pass, update the repository
      update_repository
    fi
    ;;
  
  check)
    # Check the repository before attempting to check for updates
    if check_local_repository; then
      # Get the number of commits that differ between the local and remote repositories
      local commit_diff_count=$(get_commit_diff_count)

      if [ "$commit_diff_count" -gt 0 ]; then
        local remote_name=$(git remote show)
        local branch_name=$(git rev-parse --abbrev-ref HEAD)
        echo "There are $commit_diff_count updates to be installed with changes:"
        git log --oneline HEAD.."$remote_name/$branch_name"

        # Ask the user if they want to update
        read -q "REPLY?Do you want to install the new version? (y/n): "
        echo
        if [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]; then
          # If the user agrees, perform the update
          update_repository
        else
          echo "Update cancelled. You can always update manually with 'omde update'"
        fi
      else
        echo "Your development environment is alreay up-to-date."
      fi
    fi
    ;;
  
  *)
    echo "Usage: $0 {check|update}"
    cd "$original_dir"
    exit 1
    ;;
esac

# Return to the original working directory
cd "$original_dir"

