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
declare IMAGE_HTTP
declare IMAGE_DATABASE
declare BIN_DOCKER
declare BIN_SYSCTL

# Set default values
# ###########################################################################
MIN_BASH_VERSION=3
DOCKERF_VER_MAJOR=''
DOCKERF_VER_MID=''
DOCKERF_VER_MINOR=''
IMAGE_HTTP='flisys/http'
IMAGE_DATABASE='flisys/database'
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
  # check if have something to process
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
  # check if have something to process
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

  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to check Docker Image Version. Invalid parameters. Exiting..."
    exit 1
  fi

  dck_img_ver="$(grep -i "flisys_version" "${1}" | sed 's/"//g' | awk -F "=" '{ print $2 }')"
  
  if test -z "$(echo "${dck_img_ver}" | grep -E '^"?[0-9]+\.[0-9]+\.[0-9]+"?$')"; then
    echo "Invalid Dockerfile version of image. Exiting..."
    exit 1
  fi

  echo "${dck_img_ver}"
}

# Split version from Dockerfile into Major, Mid, Minor
function split_dockerfile_version() {
  # check if have something to process
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

# check if a docker image already exists
function check_image_exists() {
  local flisys_images
  local image_version

  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to check if image already exists. Invalid parameters. Exiting..."
    exit 1
  fi

  # set image version target
  image_version="${DOCKERF_VER_MAJOR}.${DOCKERF_VER_MID}.${DOCKERF_VER_MINOR}"

  flisys_images="$(eval ""${BIN_DOCKER}" images 2>/dev/null" | grep -i "${1}")"
  if test ! -z "${flisys_images}"; then
    while IFS= read -r LINE; do
      if test "$(echo "${LINE}" | awk '{ print $2 }')" = "${image_version}"; then
        echo "${LINE}"
        break
      fi
    done <<< "$(echo "${flisys_images}")"
  fi 
}

# Ask to user if an image can be deleted
function ask_for_delete() {
  local choice
  local attempts

  attempts=1

  while test "${attempts}" -lt 4; do
    echo -n "An image with same version already exists. Do you want to delete it and its containers? [Y/n]: "
    read choice

    case "${choice}" in
      "Y"|"y"|"N"|"n")
        user_choice="$(echo "${choice}" | tr '[A-Z]' '[a-z]')"
        break
        ;;
      *)
        echo "Invalid choice, please inform a valid one! [${attempts}/3]"
        ;;
    esac

    # increase loop counter
    attempts=$(( attempts + 1 ))
  done
}

# Delete a Docker Image and its containers
function delete_image() {
  local flisys_image
  local image_version
  local image_id
  local image_sha256_raw
  local image_sha256

  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to start deletion of a Docker Image. Invalid parameters. Exiting..."
    exit 1
  fi

  # set image version target
  image_version="${DOCKERF_VER_MAJOR}.${DOCKERF_VER_MID}.${DOCKERF_VER_MINOR}"

  # get image
  while IFS= read -r LINE; do
    if test "$(echo "${LINE}" | awk '{ print $2 }')" = "${image_version}"; then
      flisys_image="${LINE}"
      break
    fi
  done <<< "$(eval ""${BIN_DOCKER}" images 2>/dev/null" | grep -i "${1}")"

  # check if image was found
  if test -z "${flisys_image}"; then
    echo "The image ${1} was not found to proceed deletion. Exiting..."
    exit 1
  fi

  # get image id
  image_id="$(echo "${flisys_image}" | awk '{ print $3 }')"
  if test -z "${image_id}"; then
    echo "Failed to get Image ID from ${1}. Exiting..."
    exit 1
  fi

  # get image sha256
  image_sha256_raw="$(eval ""${BIN_DOCKER}" inspect "${image_id}" 2>/dev/null" | grep -i "id")"
  if test -z "${image_sha256_raw}"; then
    echo "Failed to get SHA256 from ${1} image. Exiting..."
    exit 1
  fi

  # apply filter
  image_sha256="$(filter_image_sha256 "${image_sha256_raw}")"

  # check if have containers
  # count how many container this image have
  # if have no containers, just drop this section going directly to image delete

  # ///////////////////////////////////////

  # get containers
  while IFS= read -r CONTAINER; do
    delete_container "${CONTAINER}"
  done <<< "$(get_containers "${image_sha256}")"

  # delete image

  echo "${1}"
  echo "${flisys_image}"
  echo "${image_id}"
  echo "${image_sha256}"

}

# Remove unused characters
function filter_image_sha256() {
  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to filter SHA256 from a Docker Image. Invalid parameters. Exiting..."
    exit 1
  fi

  # filter it
  echo "$(echo "${1}" | sed 's/"//g;s/.$//g' | awk '{ print $2 }')"
}

# Get all containers based on a specific image
function get_containers() {
  local container_id
  local container_sha256_raw
  local container_sha256
  local to_response

  to_response=''

  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to get containers. Invalid parameters. Exiting..."
    exit 1
  fi

  # get containers list
  while IFS= read -r LINE; do
    # get container id
    container_id="$(echo "${LINE}" | awk '{ print $1 }')"
    if test -z "$(echo "${container_id}" | grep -ivE '[^a-zA-Z0-9]')"; then
      echo "Invalid container id. Exiting..."
      exit 1
    fi

    # check if this container have orgin from image target
    container_sha256_raw="$(eval ""${BIN_DOCKER}" inspect "${container_id}" 2>/dev/null" | grep -iE '"image":[[:space:]]"sha256')"
    if test -z "${container_sha256_raw}"; then
      echo "Container SHA256 not found. Exiting..."
      exit 1
    fi

    container_sha256="$(filter_image_sha256 "${container_sha256_raw}")"
    if test -z "${container_sha256}"; then
      echo "Failed to get SHA256 from container. Exiting..."
      exit 1
    fi

    # check if this container is from target image
    if test "${1}" = "${container_sha256}"; then
      # add this container to response
      if test -z "${to_response}"; then
        to_response="${container_id}"
      else
        to_response="$(echo "${to_response}\n${container_id}")"
      fi
    fi
  done <<< "$(eval ""${BIN_DOCKER}" ps -a 2>/dev/null" | grep -iv "container id")"

  echo -e "${to_response}"
}

# Delete a specific container
function delete_container() {
  # check if have something to process
  if test "${#}" -eq 0; then
    echo "Impossible to get containers. Invalid parameters. Exiting..."
    exit 1
  fi

  if test "$(eval ""${BIN_DOCKER}" stop "${1}" >/dev/null 2>&1 && "${BIN_DOCKER}" rm "${1}" >/dev/null 2>&1; echo "${?}"")" -eq 0; then
    echo "Container ${1} deleted."
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
export -f check_image_exists
export -f ask_for_delete
