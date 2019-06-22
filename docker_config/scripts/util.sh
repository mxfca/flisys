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

# Global Variables
# ###########################################################################
declare MIN_BASH_VERSION
declare DOCKERF_VER_MAJOR
declare DOCKERF_VER_MID
declare DOCKERF_VER_MINOR
declare BIN_DOCKER
declare BIN_SYSCTL

# Set default values
# ###########################################################################
MIN_BASH_VERSION=3
DOCKERF_VER_MAJOR=''
DOCKERF_VER_MID=''
DOCKERF_VER_MINOR=''
BIN_DOCKER="$(which docker)"
BIN_SYSCTL="$(which systemctl)"

# Check Bash version
function check_bash_version() {
	if test "${BASH_VERSION%%.*}" -lt "${MIN_BASH_VERSION}"; then
		echo "FliSys Docker Images require at lease Bash version 3 to run. Exiting..."
		exit 1
	fi
}

# Check if a given path exists
function path_exists() {
  if test "${#}" -eq 0; then
    echo "Impossible to check if path exists. Invalid parameters. Exiting..."
    exit 1
  fi

  if test -d "${1}"; then
    echo "${1}"
  fi
}

# Check if file exists in a given path
function file_exists() {
  if test "${#}" -eq 0; then
    echo "Impossible to check if a file exists. Invalid parameters. Exiting..."
    exit 1
  fi

  if test -f "${1}"; then
    echo "${1}"
  fi
}

# Extract the version of docker image from Dockerfile
function find_dockerfile_version() {
  local dck_img_ver

  if test "${#}" -eq 0; then
    echo "Impossible to check Docker Image Version. Invalid parameters. Exiting..."
    exit 1
  fi

  dck_img_ver="$(grep -i "flisys_version" "${1}" | awk -F "=" '{ print $2 }')"
  
  if test -z "$(echo "${dck_img_ver}" | grep -E '^"?[0-9]+\.[0-9]+\.[0-9]+"?$')"; then
    echo "Invalid Dockerfile version of image. Exiting..."
    exit 1
  fi

  echo "${dck_img_ver}"
}

# Split version from Dockerfile into Major, Mid, Minor
function split_dockerfile_version() {
  if test "${#}" -eq 0; then
    echo "Impossible to split version from Dockerfile. Invalid parameters. Exiting..."
    exit 1
  fi

  DOCKERF_VER_MAJOR="$(echo "${1}" | sed 's/"//g' | awk -F "." '{ print $1 }')"
  DOCKERF_VER_MID="$(echo "${1}" | sed 's/"//g' | awk -F "." '{ print $2 }')"
  DOCKERF_VER_MINOR="$(echo "${1}" | sed 's/"//g' | awk -F "." '{ print $3 }')"

  if test -z "$(echo ${DOCKERF_VER_MAJOR} | grep -E '^[0-9]+$')"; then
    echo "Invalid major version from Dockerfile. Exiting..."
    exit 1
  elif test -z "$(echo ${DOCKERF_VER_MID} | grep -E '^[0-9]+$')"; then
    echo "Invalid middle version from Dockerfile. Exiting..."
    exit 1
  elif test -z "$(echo ${DOCKERF_VER_MINOR} | grep -E '^[0-9]+$')"; then
    echo "Invalid minor version from Dockerfile. Exiting..."
    exit 1
  fi
}

# check if docker service is running
function check_docker_service() {
  local command_status

  if test -z "${BIN_SYSCTL}"; then
    echo "It appears that your Linux distribution does not works with systemctl. Exiting..."
    exit 1
  fi

  command_status="$(eval "${BIN_SYSCTL} status docker 2>/dev/null" | grep -i "active:" | awk -F ":" '{ print $2 }' | awk '{ print $1 }')"

  if test -z "${command_status}"; then
    echo "Failed to identify if docker service is running. Exiting..."
    exit 1
  elif test "${command_status}" != "active"; then
    # just print blank line to fail on caller
    echo ""
  else
    # Docker service is up and running
    echo "${command_status}"
  fi
}

# Export Global Functions
# ###########################################################################
export -f check_bash_version
export -f path_exists
export -f file_exists
export -f find_dockerfile_version
export -f split_dockerfile_version
export -f check_docker_service
