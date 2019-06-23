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
# ###########################################################################
declare SCRIPT_PATH
declare HTTP_PATH
declare DOCKER_FILE

# Default Values
# ###########################################################################
SCRIPT_PATH="$(cd "$(dirname "${0}")" && pwd -P)"
HTTP_PATH="$(dirname "${SCRIPT_PATH}")/http"
DOCKER_FILE="${HTTP_PATH}/Dockerfile"

# Add auxiliary script
# ###########################################################################
. "${SCRIPT_PATH}/util.sh"

# Startup function, not logic in it, just flow
# ###########################################################################
function main() {
	local valid_path
	local image_main_version
	local user_choice

	user_choice=''

	check_bash_version

	if test -z "$(path_exists "${HTTP_PATH}")"; then
		echo "Path to FliSys HTTP Service not found. Exiting..."
		exit 1
	fi

	if test -z "$(file_exists "${DOCKER_FILE}")"; then
		echo "Dockerfile is missing in HTTP Service path. Exiting..."
		exit 1
	fi

	image_main_version="$(find_dockerfile_version "${DOCKER_FILE}")"
	if test -z "${image_main_version}"; then
		echo "Invalid Dockerfile version of image. Exiting..."
		exit 1
	fi

	split_dockerfile_version "${image_main_version}"

	if test -z "${BIN_DOCKER}"; then
		echo "Docker service is not installed or not in your environment variable. Exiting..."
		exit 1
	fi

	if test -z "$(check_docker_service)"; then
		echo "Docker service is not running. Please, start it before proceed."
		echo "Try this command as root: systemctl start docker"
		echo "Exiting..."
		exit 1
	fi

	# Check if already have an image at same version
	if test ! -z "$(check_image_exists "${IMAGE_HTTP}")"; then
		# ask to delete it first (including its containers)
		ask_for_delete

		# Check if user aswered it
		if test -z "${user_choice}"; then
			echo "You must choose a valid option, otherwise can not proceed. Exiting..."
			exit 1
		elif test "${user_choice}" = "n"; then
			echo -n "You choosed not delete an image of FliSys HTTP Service that is at same version. "
			echo "In this case, it is impossible to proceed once it will be overwritten. Exiting..."
			exit 0
		fi

		delete_image "${IMAGE_HTTP}"
	fi
	

	# create a new image

	# display docker images to evidence the creation of new image

	echo "${image_main_version}"
	echo "${DOCKERF_VER_MAJOR}"
	echo "${DOCKERF_VER_MID}"
	echo "${DOCKERF_VER_MINOR}"

	echo "all good"
}

# Start the script
# ###########################################################################
main "${@}"