#!/usr/bin/env bash
# ########################################################################### #
#
# 				'########:'##:::::::'####::'######::'##:::'##::'######::
# 				 ##.....:: ##:::::::. ##::'##... ##:. ##:'##::'##... ##:
# 				 ##::::::: ##:::::::: ##:: ##:::..:::. ####::: ##:::..::
# 				 ######::: ##:::::::: ##::. ######::::. ##::::. ######::
# 				 ##...:::: ##:::::::: ##:::..... ##:::: ##:::::..... ##:
# 				 ##::::::: ##:::::::: ##::'##::: ##:::: ##::::'##::: ##:
# 				 ##::::::: ########:'####:. ######::::: ##::::. ######::
# 				..::::::::........::....:::......::::::..::::::......:::
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
# ################
declare SCRIPT_PATH
declare FLISYS_ENVIRONMENT
declare PARAM_FROM_DEPLOY

# Default Values
# ################
SCRIPT_PATH="$(cd "$(dirname "${0}")" && pwd -P)"
FLISYS_ENVIRONMENT="production"
PARAM_FROM_DEPLOY="yes"

# Add auxiliary script
# ################
# shellcheck source=/dev/null
. "${SCRIPT_PATH}/util.sh"

# ########################################################################## #
# Execution
# ########################################################################## #

# Startup function
# ################
function main() {
  local bin_bash
  local caller_script

  # welcome
  usr_message "Deploy" "Welcome to FliSys deploy!" "no" "yes"

  # check operating system
  is_linux
  get_os

  # set systemd
  set_systemd

  # get command line arguments (if available)
  get_arguments "${@}"

  # check minimum bash version for linux
  check_bash_version "${OS_NAME}"

  # get bash binary path
  bin_bash="$(command -v bash)"

  # check error
  if test -z "${bin_bash}"; then
    usr_message "Deploy" "Path to binary bash was not found. Exiting..."  "yes" "yes"
    exit 1
  fi

  # prepare http data
  usr_message "Deploy" "Starting preparation for FliSys HTTP Docker Image"  "yes" "no"
  caller_script="${bin_bash} $(filter_path "${SCRIPT_PATH}")/prep_http_image.sh --environment=${FLISYS_ENVIRONMENT} --from=${PARAM_FROM_DEPLOY}"
  if test ! -z "${OS_NAME}"; then
    caller_script="${caller_script} --osystem=${OS_NAME}"
  fi
  eval "${caller_script}"

  # prepare database data
  usr_message "Deploy" "Starting preparation for FliSys Database Docker Image"  "yes" "no"
  caller_script="${bin_bash} ${SCRIPT_PATH}/prep_db_image.sh --environment=${FLISYS_ENVIRONMENT}"
  if test ! -z "${OS_NAME}"; then
    caller_script="${caller_script} --osystem=${OS_NAME}"
  fi
  eval "${caller_script}"

  # generate images

  # deploy containers
}

# ########################################################################## #
# Helper functions
# ########################################################################## #

function get_arguments() {
  # check if have something to process
  if test "${#}" -eq 0; then
    usr_message "Deploy" "Missing argument <environment>" "yes" "yes"
    exit 1
  fi

  # get arguments
  while test "${#}" -gt 0; do
    case "${1}" in
      --environment=*) FLISYS_ENVIRONMENT="$(echo "${1#*=}" | tr '[:upper:]' '[:lower:]')"; shift 1;; # string
      *) usr_message "Deploy" "Unknown option: ${1}" "yes" "yes"; exit 1;;
    esac
  done

  # check for error
  if test -z "${FLISYS_ENVIRONMENT}" -o -z "$(echo "${FLISYS_ENVIRONMENT}" | grep -E '(production|development)')"; then
    usr_message "Deploy" 'Invalid argument: <environment>. Should be "production" or "development".' "yes" "yes"
    exit 1
  fi
}

# ########################################################################## #
# Start the script
# ########################################################################## #
main "${@}"
# ./flisys_deploy.sh --environment=production
