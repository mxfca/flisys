#!/usr/bin/env bash
# ########################################################################### #
#
#           '########:'##:::::::'####::'######::'##:::'##::'######::
#            ##.....:: ##:::::::. ##::'##... ##:. ##:'##::'##... ##:
#            ##::::::: ##:::::::: ##:: ##:::..:::. ####::: ##:::..::
#            ######::: ##:::::::: ##::. ######::::. ##::::. ######::
#            ##...:::: ##:::::::: ##:::..... ##:::: ##:::::..... ##:
#            ##::::::: ##:::::::: ##::'##::: ##:::: ##::::'##::: ##:
#            ##::::::: ########:'####:. ######::::: ##::::. ######::
#           ..::::::::........::....:::......::::::..::::::......:::
#
# ########################################################################### #
# This file is part of FliSys.
# 
# FliSys is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version
# 
# FliSys is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details
# 
# You should have received a copy of the GNU General Public License
# along with FliSys. If not, see <https://www.gnu.org/licenses/>.
# ########################################################################### #

# Set Options
# ###########################################################################
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
if test "${BASH_VERSION%%.*}" -gt '2'; then
	set -o pipefail # do not hide errors within pipes
fi

# Global Vars
# ###########################################################################
declare SCRIPT_PATH

# Default Values
# ###########################################################################
SCRIPT_PATH="$(cd "$(dirname "${0}")" && pwd -P)"

# Startup function, not logic in it, just flow
# ###########################################################################
function main() {
	local valid_path

  valid_path=''

  if test -z "${valid_path}"; then
    echo "Error message. Exiting..."
    exit 1
  fi
}

# Start the script
# ###########################################################################
main "${@}"
# usage: ./script_name.sh "option1" "option2" "optionN"