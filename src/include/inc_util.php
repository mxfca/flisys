<?php
/* *************************************************************************** * 
 * 
 *
 *            '########:'##:::::::'####::'######::'##:::'##::'######::
 *             ##.....:: ##:::::::. ##::'##... ##:. ##:'##::'##... ##:
 *             ##::::::: ##:::::::: ##:: ##:::..:::. ####::: ##:::..::
 *             ######::: ##:::::::: ##::. ######::::. ##::::. ######::
 *             ##...:::: ##:::::::: ##:::..... ##:::: ##:::::..... ##:
 *             ##::::::: ##:::::::: ##::'##::: ##:::: ##::::'##::: ##:
 *             ##::::::: ########:'####:. ######::::: ##::::. ######::
 *            ..::::::::........::....:::......::::::..::::::......:::
 *
 * *************************************************************************** *
 * This file is part of FliSys.
 * 
 * FliSys is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version
 * 
 * FliSys is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 * 
 * You should have received a copy of the GNU General Public License
 * along with FliSys. If not, see <https://www.gnu.org/licenses/>.
 * *************************************************************************** *
 * @author Maxx Fonseca
 * @copyright GNU General Public License 3
 * *************************************************************************** *
 */

/**
 * @class Util
 * @brief A static class that contains basic methods
 * @details This is a static class and does not need to be instantiated,
 *          instead just call Util::Method(params). The Util Class contains
 *          basic algorithms to help doing things more easy.
 */
class Util {
  /**
   * @brief Check if a string have some content and a minimum amount of characters
   * @param string $to_check The string to be checked
   * @param integer $min_amount The minimum amount of characters that $to_check must have. Default is 0.
   * @return boolean
   */
  public static function hasContentString($to_check = null, $min_chars = 0) {
    if ( is_null($to_check) || strlen(trim($to_check)) < intval($min_chars) ) return false;
    return true;
  }


}
?>