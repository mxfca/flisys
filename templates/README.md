# FliSys Templates

Here you can find the templates of mainly files in order to help you to start. These files already have headers, license information, documentation comments and some examples that must be replaced or even deleted.

## Class Template

**Filename**: template_class.php  
**Destination Path**: /src/include  
**Documentation Comments**: Doxygen format

This file is used as template for new classes, just copy it to destination path renaming as **inc_<class_name>.php**.

A class should have all related tasks about the objective. For example, if you want to create a class that handle exportation files, start naming it as inc_export.php. Inside the file, after you declare the class export, you should cover all methods related to exportation files, such as: export a desired table as csv or as openFileDocument.

**DO NOT FORGET** that each method in a class should be specialist, that is, you need to break up your code in many pieces, where each method just do only one thing.

## Ordinary Page Template

**Filename**: template_page.php  
**Destination Path**: /src  
**Documentation Comments**: Doxygen format

This file is used as template for new ordinary pages, just copy it to destination path renaming as **page_title.php**.

This file can contains HTML tags, Fonts imports, CSS imports and calls, PHP Class declarations and its methods calls. It is strongly recommended to not use logic (but it's not prohibited) in this file instead, put all logic things into classes and (just a very small portion) javascript files.

## Support Page Template

**Filename**: template_support.php  
**Destination Path**: /src
**Documentation Comments**: Doxygen format

This file is used as template for new support pages, just copy it to destination path renaming as **page_title_support.php**.

This file receive actions mainly from javascripts files, but also can be ordinary pages. It can only contains PHP, such as: imports of classes, classes declarations, initializations and its methods calls, also can contain a small portion of logic.

## Javascript Template


## Shell Script Template

