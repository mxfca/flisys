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

  /**
   * @brief This method choose a language to be used by FliSys
   * @param string $browser_language User's browser languages
   * @param array $supported_languages FliSys supported languages
   * @return string Returns a string with two characters that means the language to be set. Default is "en".
   */
  public static function chooseLanguage($browser_language = null, $supported_languages = []) {
    /**
     * @var string $default_language A supported language to be setted to user. Default is English.
     * @var array $user_languages Just a conversion to array the param $browser_language
     */
    $default_language = "en";
    $user_languages = [];

    // check if have something to process
    if ( is_null($browser_language) || strlen(trim($browser_language)) < 2 ) return $default_language;

    // check if have an array of supported languages
    if ( is_null($supported_languages) || !is_array($supported_languages) || count($supported_languages) < 1 ) $supported_languages = [ $default_language ];

    // check if browser have more available languages
    if ( preg_match("/;/", trim($browser_language)) > 0 ) {
      $user_languages = explode(";", $browser_language);
    } else {
      $user_languages = [ $browser_language ];
    }

    // try to find a supporte language
    foreach ( $user_languages as $key => $value) {
      if ( in_array(trim(substr($value, 0, 2)), $supported_languages) ) {
        // set language
        $default_language = trim($value);
        break;
      }
    }

    // finish
    return $default_language;
  }
}
?>
