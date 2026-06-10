#!/bin/zsh

print_usage() {
  echo "Usage: omde py-init [venv_dir]"
  echo "  Uses the active virtual environment when VIRTUAL_ENV is set."
  echo "  Otherwise, venv_dir defaults to .venv."
}

while getopts ":h" option; do
  case $option in
    h)
      print_usage
      exit 0
      ;;
    \?)
      echo "Invalid option, use '-h' to print help"
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [ "$#" -gt 1 ]; then
  print_usage
  exit 1
fi

if [ -n "$1" ]; then
  venv_dir="$1"
  if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" != "$venv_dir" ]; then
    echo "Warning: active virtual environment at $VIRTUAL_ENV will be ignored."
    echo "Installing into explicitly requested environment at $venv_dir."
  fi
elif [ -n "$VIRTUAL_ENV" ]; then
  venv_dir="$VIRTUAL_ENV"
else
  venv_dir=".venv"
fi
python_exe=`which python3`

if [ ! -x "$python_exe" ]; then
  echo "Error: python3 not found."
  exit 1
fi

# Keep this list aligned with the Python LSPs enabled in config/init.lua.
python_tools=(ruff pyright)

if [ ! -d "$venv_dir" ]; then
  echo "Creating Python virtual environment at $venv_dir..."
  "$python_exe" -m venv "$venv_dir" || { echo "Error: Failed to create virtual environment."; exit 1; }
else
  echo "Using existing Python virtual environment at $venv_dir..."
fi

venv_python="$venv_dir/bin/python"

if [ ! -x "$venv_python" ]; then
  echo "Error: $venv_dir does not look like a Python virtual environment."
  exit 1
fi

echo "Installing Python tooling for nvim: ${python_tools[*]}..."
"$venv_python" -m pip install --upgrade pip || { echo "Error: Failed to upgrade pip."; exit 1; }
"$venv_python" -m pip install --upgrade "${python_tools[@]}" || { echo "Error: Failed to install Python tooling."; exit 1; }

echo "Finished Python virtual environment initialization."
if [ "$VIRTUAL_ENV" != "$venv_dir" ]; then
  echo "Activate it with: source $venv_dir/bin/activate"
fi
