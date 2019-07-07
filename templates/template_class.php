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
 * @author Your Name
 * @copyright GNU General Public License 3
 * *************************************************************************** *
 */

/**
 * @class tpt_class_name
 * @brief A short description of the purpose of this class in one line only
 * @details A long description
 *          using multiline
 *          (if necessary multiline use)
 */
class tpt_class_name {
  /** -- Remove this line -- Declare and document all class variables here --
   * @var object $db
   * @brief Contains database class object
   * @var integer $count
   * @brief A counter for...
   */
  protected $db = null;
  protected $count = 0;

  /**
   * @brief Class initialization
   * @details A long description
   *          using multiline
   *          (if necessary multiline use)
   * @param object $dbObj Database object. Default is null.
   * @return void
   */
  function __contruct($dbObj = null) {
    $this->db = $db;
  }

  /**
   * @brief A short description of this method
   * @details A long description
   *          using multiline
   *          (if necessary multiline use)
   * @param integer $base Number to be incremented
   * @param integer $add Number to increment
   * @return integer
   */
  protected function sum($base = 0, $add = 0) {
    // must have validation if all parameters is OK before proceed
    return $base + $add;
  } 

  /**
   * @brief A short description
   * @details A long description
   *          using multiline
   *          (if necessary multiline use)
   * @param integer $base Number to be multiplied
   * @param integer $multi Number to multiply
   * @return integer
   */
  private function multi($base = 0, $multi = 0) {
    // must have validation if all parameters is OK before proceed
    return $base * $multi;
  }
}
?>
