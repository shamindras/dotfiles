#!/usr/bin/env bash

set -Eeuo pipefail

# install homebrew (https://brew.sh/)
# Check to see if Homebrew is installed, and install it if it is not
# source: https://gist.github.com/ryanmaclean/4094dfdbb13e43656c3d41eccdceae05
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }