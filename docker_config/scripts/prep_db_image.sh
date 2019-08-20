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
declare DATABASE_PATH
declare DOCKER_FILE
declare CONTAINER_ENVIRONMENT
declare GEN_CERT
declare CA_RSA_KEY
declare CA_RSA_CERT
declare SERVER_KEY
declare SERVER_KEY_REQ
declare SERVER_CERT
declare CLIENT_KEY
declare CLIENT_REQ
declare CLIENT_CERT

# Default Values
# ################
SCRIPT_PATH="$(cd "$(dirname "${0}")" && pwd -P)"
DATABASE_PATH="$(dirname "${SCRIPT_PATH}")/database"
CONTAINER_ENVIRONMENT="production"
GEN_CERT="${DATABASE_PATH}/cert/gen.cert"
CA_RSA_KEY="${DATABASE_PATH}/cert/mysql-ca-key.pem"
CA_RSA_CERT="${DATABASE_PATH}/cert/mysql-ca-cert.pem"
SERVER_KEY="${DATABASE_PATH}/cert/mysql-server-key.pem"
SERVER_KEY_REQ="${DATABASE_PATH}/cert/mysql-server-req.pem"
SERVER_CERT="${DATABASE_PATH}/cert/mysql-server-cert.pem"
CLIENT_KEY="${DATABASE_PATH}/cert/mysql-client-key.pem"
CLIENT_REQ="${DATABASE_PATH}/cert/mysql-client-req.pem"
CLIENT_CERT="${DATABASE_PATH}/cert/mysql-client-cert.pem"

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

  get_arguments "${@}"
  check_bash_version "${OS_NAME}"

  if test -z "${PARAM_FROM_DEPLOY}" -o "${PARAM_FROM_DEPLOY}" != "yes"; then
    get_os
  fi

  set_environment

  if test -z "$(path_exists "${DATABASE_PATH}")"; then
    usr_message "Prep. DB" "Path to FliSys Database Service not found. Exiting..."
    exit 1
  fi

  if test -z "$(file_exists "${DOCKER_FILE}")"; then
    usr_message "Prep. DB" "Dockerfile is missing in Database Service path. Exiting..."
    exit 1
  fi

  image_main_version="$(find_dockerfile_version "${DOCKER_FILE}")"
  if test -z "${image_main_version}"; then
    usr_message "Prep. DB" "Invalid Dockerfile version of image. Exiting..."
    exit 1
  fi

  split_dockerfile_version "${image_main_version}"

  if test -z "${BIN_DOCKER}"; then
    usr_message "Prep. DB" "Docker service is not installed or not in your environment variable. Exiting..."
    exit 1
  fi

  if test -z "$(check_docker_service)"; then
    usr_message "Prep. DB" "Docker service is not running. Please, start it before proceed."
    echo -e "\tTry this command as root: systemctl start docker"
    echo "Exiting..."
    exit 1
  fi

  # Check if already have an image at same version
  if test ! -z "$(check_image_exists "${IMAGE_DATABASE}")"; then
    # ask to delete it first (including its containers)
    ask_user "An image with same version already exists. Do you want to delete it and its containers?"

    # Check if user aswered it
    if test -z "${USER_CHOICE}"; then
      usr_message "Prep. DB" "You must choose a valid option, otherwise can not proceed. Exiting..."
      exit 1
    elif test "${USER_CHOICE}" = "n"; then
      usr_message "Prep. DB" "You choosed not delete an image of FliSys Database Service that is at same version. In this case, it is impossible to proceed once it will be overwritten. Exiting..."
      exit 0
    fi

    delete_image "${IMAGE_DATABASE}"
  fi

  # check for old certificates
  if test ! -z "$(check_old_certs)"; then
    ask_user "An old database certificate was found. Do you want to delete it to proceed?"

    # Check if user aswered it
    if test -z "${USER_CHOICE}"; then
      usr_message "Prep. DB" "You must choose a valid option, otherwise can not proceed. Exiting..."
      exit 1
    elif test "${USER_CHOICE}" = "n"; then
      usr_message "Prep. DB" "You choosed not delete an old database certificate. In this case, it is impossible to proceed once it will be overwritten. Exiting..."
      exit 0
    fi

    del_old_certificate
  fi

  # ask user for certificate params
  prep_certificate

  # create SSL for the server
  create_server_ssl

  # create client certificate
  create_client_ssl

  # all done
  echo ""
  usr_message "Prep. DB" "All set to FliSys Database Image."
}

function set_environment() {
  local file_path

  file_path="$(dirname "$(dirname "${SCRIPT_PATH}")")"

  if test ! -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E 'production')"; then
    DOCKER_FILE="${file_path}/Dockerfile"
    usr_message "Prep. DB" "Set environment as Production"
  else
    DOCKER_FILE="${file_path}/Dockerfile-dev"
    usr_message "Prep. DB" "Set environment as Development"
  fi
}

function del_old_certificate() {
  rm -f "${DATABASE_PATH}/cert/*.pem"
}

function check_old_certs() {
  local file_count
  local file

  file_count=0

  for file in ${DATABASE_PATH}/cert; do
    if test "${file}" != "gen.cert"; then
      file_count=$(( file_count + 1 ))
    fi
  done

  if test "${file_count}" -gt 0; then
    echo "${file_count}"
  fi
}

function prep_certificate() {
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
  apply_cert_data "${str_tmp}" "C="
  
  # apply State
  str_tmp="$(echo "${c_state}" | tr '[:lower:]' '[:upper:]')"
  apply_cert_data "${str_tmp}" "ST="

  # apply Location
  str_tmp="$(echo "${c_location}" | tr '[:lower:]' '[:upper:]')"
  apply_cert_data "${str_tmp}" "L="

  # apply Organization
  str_tmp="$(echo "${c_organization}" | tr '[:lower:]' '[:upper:]')"
  apply_cert_data "${str_tmp}" "O="

  # apply Domain
  str_tmp="$(echo "${c_commonname}" | tr '[:upper:]' '[:lower:]')"
  apply_cert_data "${str_tmp}" "CN="
}

function chk_cert() {
  local output

  # check if have something to process
  if test "${#}" -ne 2; then
    usr_message "Prep. DB" "Invalid value during server certificate checking. Exiting..."
    exit 1
  fi

  if test -z "${2}"; then
    usr_message "Prep. DB" "Invalid value of ${1}. Exiting..."
    exit 1
  fi

  case "${1}" in
    "Country")
      output="$(echo "${2}" | grep -E '^[a-zA-Z]{2}$'|| true)"
      ;;
    "State")
      output="$(echo "${2}" | grep -E '^[a-zA-Z]{2}$'|| true)"
      ;;
    "City")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9]+$'|| true)"
      ;;
    "Company")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9]+$'|| true)"
      ;;
    "Domain")
      output="$(echo "${2}" | grep -E '^[a-zA-Z0-9/_\.-]+$'|| true)"
      ;;
  esac

  if test -z "${output}"; then
    usr_message "Prep. DB" "Invalid value format of ${1}. Exiting..."
    exit 1
  fi
}

function apply_cert_data() {
  local bin_sed
  local file_path
  local output

  # check if have something to process
  if test "${#}" -ne 2; then
    usr_message "Prep. DB" "Invalid value while saving server certificate data. Exiting..."
    exit 1
  fi

  # get binary path
  bin_sed="$(command -v sed)"

  # check error
  if test -z "${bin_sed}"; then
    usr_message "Prep. DB" "SED is not installed or not able to use. Aborting..."
    return
  fi

  # set path
  file_path="${GEN_CERT}"

  # execute change
  output="$(eval "${bin_sed} -i \"/${2}/c\${2}\\\"${1}\\\"\" ${file_path} 2>&1")"

  # check error
  if test ! -z "${output}"; then
    usr_message "Prep. DB" "Failed to apply data with error:\n\t${output}"
    exit 1
  fi
}

function create_client_ssl() {
  gen_client_key
  convert_clientkey_rsa
  gen_client_cert
}

function create_server_ssl() {
  gen_ca_key
  gen_ca_certificate
  gen_server_key
  convert_serverkey_rsa
  gen_server_certificate
}

function gen_client_cert() {
  openssl x509 -req -in "${CLIENT_REQ}" -days 365 -CA "${CA_RSA_CERT}" -CAkey "${CA_RSA_KEY}" -set_serial 01 -out "${CLIENT_CERT}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to create new Client Certificate. Exiting..."
    exit 1
  fi
}

function convert_clientkey_rsa() {
  openssl rsa -in "${CLIENT_KEY}" -out "${CLIENT_KEY}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to convert Client Private Key to RSA type. Exiting..."
    exit 1
  fi
}

function gen_client_key() {
  openssl req -config "${GEN_CERT}" -newkey rsa:2048 -days 365 -nodes -keyout "${CLIENT_KEY}" -out "${CLIENT_REQ}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to generate Client Private Key. Exiting..."
    exit 1
  fi
}

function gen_server_certificate() {
  openssl x509 -req -in "${SERVER_KEY_REQ}" -days 365 -CA "${CA_RSA_CERT}" -CAkey "${CA_RSA_KEY}" -set_serial 01 -out "${SERVER_CERT}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to create new Server Certificate. Exiting..."
    exit 1
  fi
}

function convert_serverkey_rsa() {
  openssl rsa -in "${SERVER_KEY}" -out "${SERVER_KEY}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to convert Server Private Key to RSA type. Exiting..."
    exit 1
  fi
}

function gen_server_key() {
  openssl req -config "${GEN_CERT}" -newkey rsa:2048 -days 365 -nodes -keyout "${SERVER_KEY}" -out "${SERVER_KEY_REQ}"
  
  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to generate Server Private Certificate - Private Key. Exiting..."
    exit 1
  fi
}

function gen_ca_certificate() {
  openssl req -config "${GEN_CERT}" -new -x509 -nodes -days 400 -key "${CA_RSA_KEY}" -out "${CA_RSA_CERT}"
  
  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to generate CA Certificate. Exiting..."
    exit 1
  fi
}

function gen_ca_key() {
  openssl genrsa 2048 > "${CA_RSA_KEY}"

  if test "${?}" != 0; then
    usr_message "Prep. DB" "Failed to generate CA Private Key. Exiting..."
    exit 1
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
      *) usr_message "Prep. DB" "Unknown option: ${1}"; exit 1;;
    esac
  done

  # check for error
  if test -z "${CONTAINER_ENVIRONMENT}" -o -z "$(echo "${CONTAINER_ENVIRONMENT}" | grep -E '(production|development)')"; then
    usr_message "Prep. DB" 'Invalid argument: <environment>. Should be "production" or "development".'
    exit 1
  fi
}

# ########################################################################## #
# Start the script
# ########################################################################## #
main "${@}"
