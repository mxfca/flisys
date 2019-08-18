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
# @author Maxx Fonseca
# @copyright GNU General Public License 3
# ########################################################################### #
set -e
trap "echo got traped signal, exiting..." HUP INT QUIT TERM

# Start Database Service
# ----------------------------------------------------------------------------
/usr/sbin/service mysql start

# Delete Anonymous Users
# DELETE  FROM mysql.user WHERE User=''

# Delete Remote Root
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')

# Drop Test Database (if exists) and remove its privileges
# DROP DATABASE IF EXISTS test
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'

# Flush Privileges
# FLUSH PRIVILEGES


# wait until receive stop signal
# ----------------------------------------------------------------------------
echo "[hit enter key to exit] or run 'docker stop <container>'"
read -r

# Stop Database Service
# ----------------------------------------------------------------------------
/usr/sbin/service mysql stop
