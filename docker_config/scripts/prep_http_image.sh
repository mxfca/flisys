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
DOCKER_FILE=""
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

  # re-run some function in case to runnning as stand alone
  is_linux
  get_os
  set_systemd
  get_arguments "${@}"
  check_bash_version
  set_environment

  if test -z "$(path_exists "${HTTP_PATH}")"; then
    usr_message "Prep. HTTP" "Path to FliSys HTTP Service not found. Exiting..." "yes" "yes"
    exit 1
  fi

  if test -z "$(file_exists "${DOCKER_FILE}")"; then
    usr_message "Prep. HTTP" "Dockerfile is missing in HTTP Service path. Exiting..." "yes" "yes"
    exit 1
  fi

  image_main_version="$(find_dockerfile_version "${DOCKER_FILE}")"
  if test -z "${image_main_version}"; then
    usr_message "Prep. HTTP" "Invalid Dockerfile version of image. Exiting..." "yes" "yes"
    exit 1
  fi

  split_dockerfile_version "${image_main_version}"

  if test -z "${BIN_DOCKER}"; then
    usr_message "Prep. HTTP" "Docker service is not installed or not in your environment variable. Exiting..." "yes" "yes"
    exit 1
  fi

  if test -z "$(check_docker_service)"; then
    usr_message "Prep. HTTP" "Docker service is not running. Please, start it before proceed." "yes" "no"
    printf "\tTry this command as root: systemctl start docker\n"
    printf "Exiting...\n\n"
    exit 1
  fi

  # Check if already have an image at same version
  if test ! -z "$(check_image_exists "${IMAGE_HTTP}")"; then
    # ask to delete it first (including its containers)
    ask_user "An image with same version already exists. Do you want to delete it and its containers?"

    # Check if user aswered it
    if test -z "${USER_CHOICE}"; then
      usr_message "Prep. HTTP" "You must choose a valid option, otherwise can not proceed. Exiting..." "yes" "yes"
      exit 1
    elif test "${USER_CHOICE}" = "n"; then
      usr_message "Prep. HTTP" "You choosed not delete an image of FliSys HTTP Service that is at same version. In this case, it is impossible to proceed once it will be overwritten. Exiting..." "yes" "yes"
      exit 0
    fi

    delete_image "${IMAGE_HTTP}"
  fi

  # ask for proxy
  echo ""
  usr_message "Proxy Configuration" ""
  ask_user "Do you need to configure proxy for FliSys containers?"

  # Check user answer
  if test -z "${USER_CHOICE}"; then
    usr_message "Prep. HTTP" "You must choose a valid option, otherwise can not proceed. Exiting..." "no" "yes"
    exit 1
  elif test "${USER_CHOICE}" = "y"; then
    prep_proxy
  else
    usr_message "Prep. HTTP" "User informed that proxy is not required to be set to run FliSys HTTP Container." "no" "yes"
  fi

  # generate self signed certificate
  usr_message "Auto Signed Web Certificate" " "  "no" "no"
  usr_message "Prep. HTTP" "Even if you already have your own web certificate, it is necessary to create one during docker image generation." "no" "yes"
  prep_web_cert

  # configure volumes
  usr_message "Shared Directory" " " "yes" "no"
  prep_shared_dir

  # all done
  usr_message "Prep. HTTP" "All set to FliSys HTTP Image." "yes" "yes"
}

function set_environment() {
  local file_path

  file_path="$(dirname "$(dirname "${SCRIPT_PATH}")")"

  if test ! -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E 'production')"; then
    DOCKER_FILE="${file_path}/Dockerfile"
    usr_message "Prep. HTTP" "Set environment as Production" "no" "yes"
  else
    DOCKER_FILE="${file_path}/Dockerfile-dev"
    usr_message "Prep. HTTP" "Set environment as Development" "no" "yes"
  fi
}

function prep_proxy() {
  local proxy_uri
  local bin_sed
  local output

  # get binary path
  bin_sed="$(command -v sed)"

  # check error
  if test -z "${bin_sed}"; then
    usr_message "Prep. HTTP" "SED is not installed or not able to use. Aborting proxy step..." "yes" "yes"
    return
  fi

  # ask user
  echo -n "Please, inform your proxy URI (e.g. http://hostname:8080): "
  read -r proxy_uri

  # check answer
  if test -z "${proxy_uri}"; then
    usr_message "Prep. HTTP" "No proxy URI informed. Aborting proxy step..." "yes" "yes"
    return
  elif test ! -z "$(echo "${proxy_uri}" | tr '[:upper:]' '[:lower:]' | grep -E '^https://')"; then
    usr_message "Prep. HTTP" "HTTPS is reserved for internal tasks. Aborting proxy step..." "yes" "yes"
    return
  elif test ! -z "$(echo "${proxy_uri}" | tr '[:upper:]' '[:lower:]' | grep -E '^http://')" -a ! -z "$(check_proxy_uri "${proxy_uri}")"; then
    usr_message "Prep. HTTP" "Proxy URI is ${proxy_uri}" "no" "yes"
  else
    usr_message "Prep. HTTP" "Another protocol beyond HTTP should be set manually in Dockerfile. Aborting proxy step..." "yes" "yes"
    return
  fi

  # apply proxy
  output="$(eval "${bin_sed} -i \"/HTTP_PROXY/c\ENV HTTP_PROXY \\\"${proxy_uri}\\\"\" ${DOCKER_FILE} 2>&1")"

  # check error
  if test ! -z "${output}"; then
    usr_message "Prep. HTTP" "Failed to apply proxy data with error:\n\t${output}" "yes" "yes"
  fi
}

function check_proxy_uri() {
  # check if have something to process
  if test "${#}" -eq 0; then
    return
  fi

  if test ! -z "$(echo "${1}" | tr '[:upper:]' '[:lower:]' | grep -E '^(http://)?[a-zA-Z0-9_\.-]+(:[0-9]+)?$')"; then
    echo "ok"
  fi
}

function prep_web_cert() {
  local str_tmp
  local c_country
  local c_state
  local c_location
  local c_organization
  local c_commonname

  # ask user
  echo -n "Inform your Country (only 02 characters): "
  read -r c_country

  # check error
  chk_cert "Country" "${c_country}"

  # ask user
  echo -n "Inform your State (only 02 characters): "
  read -r c_state

  # check error
  chk_cert "State" "${c_state}"

  # ask user
  echo -n "Inform your City (only alphanumeric without spaces): "
  read -r c_location

  # check error
  chk_cert "City" "${c_location}"

  # ask user
  echo -n "Inform your Company (only alphanumeric without spaces): "
  read -r c_organization

  # check error
  chk_cert "Company" "${c_organization}"

  # ask user
  echo -n "Inform your Domain: "
  read -r c_commonname

  # check error
  chk_cert "Domain" "${c_commonname}"

  # apply Country
  str_tmp="$(echo "${c_country}" | tr '[:lower:]' '[:upper:]')"
  echo "${str_tmp}"
  apply_cert_data "${str_tmp}" "C="
  
  # apply State
  str_tmp="$(echo "${c_state}" | tr '[:lower:]' '[:upper:]')"
  echo "${str_tmp}"
  apply_cert_data "${str_tmp}" "ST="

  # apply Location
  str_tmp="$(echo "${c_location}" | tr '[:lower:]' '[:upper:]')"
  echo "${str_tmp}"
  apply_cert_data "${str_tmp}" "L="

  # apply Organization
  str_tmp="$(echo "${c_organization}" | tr '[:lower:]' '[:upper:]')"
  echo "${str_tmp}"
  apply_cert_data "${str_tmp}" "O="

  # apply Domain
  str_tmp="$(echo "${c_commonname}" | tr '[:upper:]' '[:lower:]')"
  echo "${str_tmp}"
  apply_cert_data "${str_tmp}" "CN="
}

function chk_cert() {
  local output

  # check if have something to process
  if test "${#}" -ne 2; then
    usr_message "Prep. HTTP" "Invalid value during web certificate checking. Exiting..." "yes" "yes"
    exit 1
  fi

  if test -z "${2}"; then
    usr_message "Prep. HTTP" "Invalid value of ${1}. Exiting..." "no" "yes"
    exit 1
  fi

  case "${1}" in
    "Country")
      output="$(echo "${2}" | grep -E '^[a-zA-Z]{2}$' || true)"
      ;;
    "State")
      output="$(echo "${2}" | grep -E '^[a-zA-Z]{2}$' || true)"
      ;;
    "City")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9]+$' || true)"
      ;;
    "Company")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9]+$' || true)"
      ;;
    "Domain")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9/_\.-]+$' || true)"
      ;;
    "SystemLogs")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9/_\.-]+$' || true)"
      ;;
    "ExternalConfiguration")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9/_\.-]+$' || true)"
      ;;
    "WebCertificate")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9/_\.-]+$' || true)"
      ;;
  esac

  if test -z "${output}"; then
    usr_message "Prep. HTTP" "Invalid value format of ${1}. Exiting..." "yes" "yes"
    exit 1
  fi
}

function apply_cert_data() {
  local bin_sed
  local file_path
  local output

  echo "apply_cert_data"

  # check if have something to process
  if test "${#}" -ne 2; then
    usr_message "Prep. HTTP" "Invalid value while saving web certificate data. Exiting..." "yes" "yes"
    exit 1
  fi

  # get binary path
  bin_sed="$(command -v sed || true)"

  # check error
  if test -z "${bin_sed}"; then
    usr_message "Prep. HTTP" "SED is not installed or not able to use. Aborting..." "yes" "yes"
    return
  fi

  # set path
  file_path="$(filter_path "${HTTP_PATH}")/gen.cert"

  # execute change
  output="$(eval "${bin_sed} -i \"/${2}/c\${2}\\\"${1}\\\"\" ${file_path} 2>&1 || true")"

  # check error
  if test ! -z "${output}"; then
    usr_message "Prep. HTTP" "Failed to apply data with error:\n\t${output}" "yes" "yes"
    exit 1
  fi
}

function prep_shared_dir() {
  local d_log
  local d_extconf
  local d_certificate

  # welcome
  usr_message "Welcome to Shared Directory Wizard" " "  "yes" "no"
  usr_message "Shared Dir." "In order to avoid data losing, it is necessary to set some paths to safe save the data. These paths must already exists." "no" "yes"

  # ask user
  echo -n "Path to System Logs: "
  read -r d_log

  # check error
  chk_cert "SystemLogs" "${d_log}"
  if test -z "$(path_exists "${d_log}")"; then
    usr_message "Shared Dir." "System Log directory does not exists. Exiting..." "yes" "yes"
    exit 1
  fi

  # ask user
  echo -n "Path to External Configuration: "
  read -r d_extconf

  # check error
  chk_cert "ExternalConfiguration" "${d_extconf}"
  if test -z "$(path_exists "${d_extconf}")"; then
    usr_message "Shared Dir." "External Configuration directory does not exists. Exiting..." "yes" "yes"
    exit 1
  fi

  # ask user
  echo -n "Path to Web Certificate: "
  read -r d_certificate

  # check error
  chk_cert "WebCertificate" "${d_certificate}"
  if test -z "$(path_exists "${d_certificate}")"; then
    usr_message "Shared Dir." "Web Certificate directory does not exists. Exiting..." "yes" "yes"
    exit 1
  fi

  # apply data
  apply_vol_data "${d_log}:/var/log:z" "WEBLOG"
  apply_vol_data "${d_extconf}:/var/www/flisys/inclue/external:z" "WEBEXTCONF"
  apply_vol_data "${d_certificate}:/etc/apache2/certs:z" "WEBCERT"
}

function apply_vol_data() {
  local bin_sed
  local file_path
  local output

  # check if have something to process
  if test "${#}" -ne 2; then
    usr_message "Prep. Shared Dir." "Invalid value while saving shared directory path. Exiting..." "yes" "yes"
    exit 1
  fi

  # get binary path
  bin_sed="$(command -v sed)"

  # check error
  if test -z "${bin_sed}"; then
    usr_message "Prep. Shared Dir." "SED is not installed or not able to use. Aborting..." "yes" "yes"
    return
  fi

  # set path
  file_path="$(dirname "${DOCKER_FILE}")/docker-compose.yml"

  # execute change
  output="$(eval "${bin_sed} -i \"/${2}/c\      - \\\"${1}\\\"\" ${file_path} 2>&1")"

  # check error
  if test ! -z "${output}"; then
    usr_message "Prep. Shared Dir." "Failed to apply data with error:\n\t${output}" "yes" "yes"
    exit 1
  fi
}

# ########################################################################## #
# Helper functions
# ########################################################################## #

function get_arguments() {
  # check if have something to process
  if test "${#}" -eq 0; then
    usr_message "Prep. HTTP" "Missing argument <environment>" "yes" "yes"
    exit 1
  fi

  # get arguments
  while test "${#}" -gt 0; do
    case "${1}" in
      --environment=*) CONTAINER_ENVIRONMENT="$(echo "${1#*=}" | tr '[:upper:]' '[:lower:]')"; shift 1;; # string
      *) usr_message "Prep. HTTP" "Unknown option: ${1}" "yes" "yes"; exit 1;;
    esac
  done

  # check for error
  if test -z "${CONTAINER_ENVIRONMENT}" -o -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E '(production|development)')"; then
    usr_message "Prep. HTTP" 'Invalid argument: <environment>. Should be "production" or "development".' "yes" "yes"
    exit 1
  fi
}

# ########################################################################## #
# Start the script
# ########################################################################## #
main "${@}"