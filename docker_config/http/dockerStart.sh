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

# Start Apache Service
# ----------------------------------------------------------------------------
/usr/sbin/service apache2 start

# wait until receive stop signal
# ----------------------------------------------------------------------------
echo "[hit enter key to exit] or run 'docker stop <container>'"
read

# Stop Apache Service
# ----------------------------------------------------------------------------
/usr/sbin/service apache2 stop
