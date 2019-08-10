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
# ################
set -o errexit # abort on nonzero exit status
set -o nounset # abort on unbound variable
if test "${BASH_VERSION%%.*}" -gt '2'; then
  set -o pipefail # do not hide errors within pipes
fi

# Global Vars
# ################
declare SCRIPT_PATH
declare HTTP_PATH
declare DOCKER_FILE
declare CONTAINER_ENVIRONMENT

# Default Values
# ################
SCRIPT_PATH="$(cd "$(dirname "${0}")" && pwd -P)"
HTTP_PATH="$(dirname "${SCRIPT_PATH}")/http"
CONTAINER_ENVIRONMENT="production"

# Add auxiliary script
# ################
# shellcheck source=/dev/null
. "${SCRIPT_PATH}/util.sh"

# ########################################################################## #
# Execution
# ########################################################################## #

# Startup function
# ###########################################################################
function main() {
  local image_main_version

  check_bash_version
  get_arguments "${@}"
  set_environment

  if test -z "$(path_exists "${HTTP_PATH}")"; then
    usr_message "Create Image" "Path to FliSys HTTP Service not found. Exiting..."
    exit 1
  fi

  if test -z "$(file_exists "${DOCKER_FILE}")"; then
    usr_message "Create Image" "Dockerfile is missing in HTTP Service path. Exiting..."
    exit 1
  fi

  image_main_version="$(find_dockerfile_version "${DOCKER_FILE}")"
  if test -z "${image_main_version}"; then
    usr_message "Create Image" "Invalid Dockerfile version of image. Exiting..."
    exit 1
  fi

  split_dockerfile_version "${image_main_version}"

  if test -z "${BIN_DOCKER}"; then
    usr_message "Create Image" "Docker service is not installed or not in your environment variable. Exiting..."
    exit 1
  fi

  if test -z "$(check_docker_service)"; then
    usr_message "Create Image" "Docker service is not running. Please, start it before proceed."
    echo -e "\tTry this command as root: systemctl start docker"
    echo "Exiting..."
    exit 1
  fi

  # Check if already have an image at same version
  if test ! -z "$(check_image_exists "${IMAGE_HTTP}")"; then
    # ask to delete it first (including its containers)
    ask_for_delete

    # Check if user aswered it
    if test -z "${USER_CHOICE}"; then
      usr_message "Create Image" "You must choose a valid option, otherwise can not proceed. Exiting..."
      exit 1
    elif test "${USER_CHOICE}" = "n"; then
      usr_message "Create Image" "You choosed not delete an image of FliSys HTTP Service that is at same version. In this case, it is impossible to proceed once it will be overwritten. Exiting..."
      exit 0
    fi

    delete_image "${IMAGE_HTTP}"
  fi

  # ask for proxy

  # generate self signed certificate

  usr_message "Create Image" "All set to FliSys HTTP Image."
}

function set_environment() {
  local file_path

  file_path="$(dirname "$(dirname "${SCRIPT_PATH}")")"

  if test ! -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E 'production')"; then
    DOCKER_FILE="${file_path}/Dockerfile"
    usr_message "Create Image" "Set environment as Production"
  else
    DOCKER_FILE="${file_path}/Dockerfile-dev"
    usr_message "Create Image" "Set environment as Production"
  fi
}

# ########################################################################## #
# Helper functions
# ########################################################################## #

function get_arguments() {
  # check if have something to process
  if test "${#}" -eq 0; then
    return
  fi

  # get arguments
  while test "${#}" -gt 0; do
    case "${1}" in
      --environment=*) CONTAINER_ENVIRONMENT="$(echo "${1#*=}" | tr '[:upper:]' '[:lower:]')"; shift 1;; # string
      *) usr_message "Create Image" "Unknown option: ${1}"; exit 1;;
    esac
  done

  # check for error
  if test -z "${CONTAINER_ENVIRONMENT}" -o -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E '(production|development)')"; then
    usr_message "Create Image" 'Invalid argument: <environment>. Should be "production" or "development".'
    exit 1
  fi
}

# ########################################################################## #
# Start the script
# ########################################################################## #
main "${@}"