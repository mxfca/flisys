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
 * @class flisys
 * @brief The general purpose class for FliSys
 * @details This class is responsible for general purpose objectives, such as:
 *          basic HTML headers and footers, includes CSS and Javascripts files.
 *          All methods that does not need a entire class, is here.
 */
class flisys {
  /**
   * @var object $db
   * @brief Contains database class object
   * @var array $jsFiles
   * @brief An array that contains all Javascript files to be included
   * @var array $cssFiles
   * @brief An array that contains all CSS files to be included
   * @var string $jsPath
   * @brief Relative path to reach Javascript files. Default value is using Apache Rewrite Module.
   * @var string $cssPath
   * @brief Relative path to reach CSS files. Default value is using Apache Rewrite Module.
   */
  private $db = null;
  private $jsFiles = [];
  private $cssFiles = [];
  private $jsPath = DIRECTORY_SEPARATOR . "js";
  private $cssPath = DIRECTORY_SEPARATOR . "css";

  /**
   * @brief Class initialization
   * @param object $dbObj Database object. Default is null.
   * @return void
   */
  function __contruct($dbObj = null) {
    $this->db = $dbObj;
  }

  /**
   * @brief Add CSS file into page
   * @details Add a CSS file from /include/css into page.
   *          Just pass the filename without the path as argument.
   * @param string $fileName
   * @return bool
   */
  public function addCSS($fileName = null) {
    // check if have something to process
    if ( is_null($fileName)
          || strlen(trim($fileName)) < 5
            || preg_match("/^[a-zA-Z0-9_\.-]+\.css$/", trim($fileName)) < 1 ) return false;

    // check if file exists
    if ( !file_exists($this->cssPath . DIRECTORY_SEPARATOR . trim($fileName)) ) return false;

    // add to array
    $this->cssFiles[] = trim($fileName);

    // finish
    return true;
  }

  /**
   * @brief Add Javascript file into page
   * @details Add a Javascript file from /include/js into page.
   *          Just pass the filename without the path as argument.
   * @param string $fileName
   * @param boolean $toBottom
   * @return boolean
   */
  public function addJS($fileName = null, $toBottom = true) {
    // check if have something to process
    if ( is_null($fileName) || strlen(trim($fileName)) < 4 ) return false;

    // check if file exists

    // add to array

    // finish
  }


  public function printHeader() {

  }
}
?>
