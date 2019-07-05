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
 * @license https://www.gnu.org/licenses/gpl-3.0.html GNU General Public License 3
 * *************************************************************************** *
 */

/**
 * A short description of the purpose of this class in one line only (must finish using period).
 * A long
 * description
 * using multiline (if necessary multiline use)
 * @method void __construct(object $dbObj)
 * @method integer sum(integer $base, integer $add) Sum two numbers
 * @method integer multi(integer $base, integer $multi) Multiply two numbers
 */
class tpt_class_name {
  /** @var object|null contains database class object */
  protected $db = null;

  /**
   * A short description (must finish using period).
   * A long description using multiline (if necessary multiline use)
   * @author Name <email@email.com>
   * @access public
   * @param object $dbObj Database object. Default is null.
   * @return void
   */
  function __contruct($dbObj = null) {
    $this->db = $db;
  }

  /**
   * A short description (must finish using period).
   * A long description using multiline (if necessary multiline use)
   * @author Name <email@email.com>
   * @access protected
   * @param integer $base Number to be incremented
   * @param integer $add Number to increment
   * @return integer
   */
  protected function sum($base = 0, $add = 0) {
    // must have validation if all parameters is integer before proceed
    return $base + $add;
  } 

  /**
   * A short description (must finish using period).
   * A long description using multiline (if necessary multiline use)
   * @author Name <email@email.com>
   * @access private
   * @param integer $base Number to be multiplied
   * @param integer $multi Number to multiply
   * @return integer
   */
  private function multi($base = 0, $multi = 0) {
    // must have validation if all parameters is integer before proceed
    return $base * $multi;
  }
}
?>
