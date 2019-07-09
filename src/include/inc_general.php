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
 * @brief Required class(es)
 */
require_once(realpath(dirname(__FILE__)) . DIRECTORY_SEPARATOR . "inc_util.php");

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
   * @var string $semanticPath
   * @brief Relative path to reach Semantic UI files. Default value is using Apache Rewrite Module.
   */
  private $db = null;
  private $jsFiles = [];
  private $cssFiles = [];
  private $jsPath = DIRECTORY_SEPARATOR . "js";
  private $cssPath = DIRECTORY_SEPARATOR . "css";
  private $semanticPath = DIRECTORY_SEPARATOR . "semantic";
  private $semanticCSS = "semantic.min.css";
  private $semanticJS = "semantic.min.js";

  /**
   * @brief Class initialization
   * @param object $db_obj Database object. Default is null.
   * @return void
   */
  function __contruct($db_obj = null) {
    $this->db = $db_obj;

    // add default values
    $this->addCSS("basic.css");
  }

  /**
   * @brief Add CSS file into page
   * @details Add a CSS file from /include/css into page.
   *          Just pass the filename without the path as argument.
   * @param string $file_name The CSS file to be included
   * @return bool
   */
  public function addCSS($file_name = null) {
    // check if have something to process
    if ( !Util::hasContentString($file_name, 5)
          || preg_match("/^[a-zA-Z0-9_\.-]+\.css$/", trim($file_name)) < 1 ) return false;

    // check if file exists
    if ( !file_exists(realpath(dirname(__FILE__)) . $this->cssPath . DIRECTORY_SEPARATOR . trim($file_name)) ) return false;

    // add to array
    $this->cssFiles[] = trim($file_name);

    // finish
    return true;
  }

  /**
   * @brief Add Javascript file into page
   * @details Add a Javascript file from /include/js into page.
   *          Just pass the filename without the path as argument.
   * @param string $file_name The Javascript file to be included
   * @param boolean $to_bottom If TRUE, this file will be include at the end of the page
   * @return bool
   */
  public function addJS($file_name = null, $to_bottom = true) {
    // check if have something to process
    if ( !Util::hasContentString($file_name, 4)
          || !is_bool($to_bottom)
            || preg_match("/^[a-zA-Z0-9_\.-]+\.js$/", trim($file_name)) < 1 ) return false;

    // check if file exists
    if ( !file_exists(realpath(dirname(__FILE__)) . $this->jsPath . DIRECTORY_SEPARATOR . trim($file_name)) ) return false;

    // add to array
    $this->jsFiles[] = array(trim($file_name), $to_bottom);

    // finish
    return true;
  }

  /**
   * @brief Internal use only. This method print to header all CSS files previouly added
   * @param boolean $add_semantic
   * @return void
   */
  private function printCSS($add_semantic = true) {
    // add semantic ui css
    if ( $add_semantic ) {
      echo "\t\t" . '<link rel="stylesheet" type="text/css" href="' . $this->semanticPath . DIRECTORY_SEPARATOR . $this->semanticCSS . '">' . "\n";
    }

    // check if have something else to add
    if ( !is_array($this->cssFiles) || count($this->cssFiles) < 1 ) return;

    // add additional css files
    foreach ($this->cssFiles as $key => $value) {
      echo "\t\t" . '<link rel="stylesheet" type="text/css" href="' . $this->cssPath . DIRECTORY_SEPARATOR . $value . '">' . "\n";
    }
  }

  /**
   * @brief Internal use only. Thie method print to header or footer all JS files previouly added
   * @param boolean $to_header
   * @param boolean $add_jquery
   * @param boolean $add_semantic
   * @return void
   */
  private function printJS($to_header = false, $add_jquery = true, $add_semantic = true) {
    // print jquery
    if ( $to_header && $add_jquery ) {
      echo "\t\t" . '<script src="' . $this->jsPath . DIRECTORY_SEPARATOR . 'jquery.min.js"></script>' . "\n";
    }

    // print semantic ui js
    if ( $to_header && $add_semantic ) {
      echo "\t\t" . '<script src="' . $this->semanticPath . DIRECTORY_SEPARATOR . 'semantic.min.js"></script>' . "\n";
    }

    // check if have something else to print
    if ( !is_array($this->jsFiles) || count($this->jsFiles) < 1 ) return;

    // print additional js files
    foreach ($this->jsFiles as $key => $value) {
      if ( $to_header && !$value[1] ) {
        echo "\t\t" . '<script src="' . $this->jsPath . DIRECTORY_SEPARATOR . $value[0] . '"></script>' . "\n";
      } elseif ( !$to_header && $value[1] ) {
        echo "\t" . '<script src="' . $this->jsPath . DIRECTORY_SEPARATOR . $value[0] . '"></script>' . "\n";
      }
    }
  }

  /**
   * @brief Print HTML header to the page
   * @param boolean $add_semantic if TRUE, will add Semantic UI framework. Default is TRUE.
   * @return void
   */
  public function printHeader($add_semantic = true) {
    // start header
    echo "<!DOCTYPE html>\n<html>\n\t<head>\n";
    echo "\t\t<meta charset=\"UTF-8\">\n";
    
    // print title page
    // @todo print title page

    // print default page config
		echo "\t\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n";
    echo "\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes\">\n";
		echo "\t\t<meta http-equiv=\"Cache-control\" content=\"no-store\">\n";
		echo "\t\t<meta http-equiv=\"Pragma\" content=\"no-cache\">\n";
		echo "\t\t<meta http-equiv=\"Expires\" content=\"0\">\n";

    // print CSS files
    $this->printCSS($add_semantic);

    // print JS files in the header
    $this->printJS(true);

    // Finish header
		echo "\t</head>\n<body>\n\n";
  }

  /**
   * @brief Print footer page and close HTML Body
   * @return void
   */
  public function printFooter() {
    // print JS files at the end of the page
    $this->printJS();

    // print modal declaration

    // print footer

    // Print copyright

    // close HTML
    echo "</body>\n";

    // Close DB Connection
  }
}
?>
