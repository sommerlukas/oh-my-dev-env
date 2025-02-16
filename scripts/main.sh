#!/bin/zsh

# Function to print usage instructions
print_usage() {
  echo "Usage:"
  echo "  omde help                - Show this help message."
  echo "  omde install <argument>  - Install tools or configuration."
  echo "    <argument> options:"
  echo "      tools   - Install tools only."
  echo "      config  - Install config only"
  echo "      all     - Install tools and config"
  echo "  omde update               - Check for updates"
}

# Handle the main commands: help, install, update
case "$1" in
  help)
    print_usage
    exit 0
    ;;

  install)
    if [ -z "$2" ] || [ "$2" = "all" ]; then
      # Execute both scripts if "all" or no additional argument
      echo "Installing tools and configuration..."
      $OMDE_DIR/scripts/tool-install.sh ${@:2} || { echo "Error: Failed to install tools."; exit 1; }
      $OMDE_DIR/scripts/config-install.sh ${@:2} || { echo "Error: Failed to install configuration."; exit 1; }
    elif [ "$2" = "tools" ]; then
      # Execute tool-install.sh if "tools"
      echo "Installing tools..."
      $OMDE_DIR/scripts/tool-install.sh ${@:2} || { echo "Error: Failed to install tools."; exit 1; }
    elif [ "$2" = "config" ]; then
      # Execute config-install.sh if "config"
      echo "Installing configuration..."
      $OMDE_DIR/scripts/config-install.sh ${@:2} || { echo "Error: Failed to install configuration."; exit 1; }
    else
      echo "Error: Invalid argument for 'install'."
      print_usage
      exit 1
    fi
    ;;
  
  update)
    # Execute update.sh when the "update" command is given
    echo "Updating repository..."
    $OMDE_DIR/scripts/update.sh check || { echo "Error: Failed to update."; exit 1; }
    ;;
  
  *)
    echo "Error: Unknown command."
    print_usage
    exit 1
    ;;
esac

