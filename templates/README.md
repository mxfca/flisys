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
**Destination Path**: /src/support  
**Documentation Comments**: Doxygen format

This file is used as template for new support pages, just copy it to destination path renaming as **page_title_support.php**.

This file receive actions mainly from javascripts files, but also can be ordinary pages. It can only contains PHP, such as: imports of classes, classes declarations, initializations and its methods calls, also can contain a small portion of logic in order to route actions received and send responses to the caller.

## Javascript Template

**Filename**: template_javascript.js  
**Destination Path**: /src/include/js  
**Documentation Comments**: Doxygen format

This file is used as template for new javascripts files, just copy it to destination path renaming as **title.js**.

This file is responsible for the communication between ordinary and support pages, it listen for actions (triggers) from ordinary pages and send it (data) to support pages to be processed, as well as the inverse way is true, get responses from support pages and send it to ordinary pages.

Another use of javascript files is to create some visual effects for users and/or pages/data transitions, in this case there is no communications between ordinary and support pages, acting as a isolated file.

## Bash Script Template

**Filename**: template_bash.sh  
**Destination Path**: /docker_config/scripts  
**Documentation Comments**: Doxygen format

This file is used as template for new automation scripts focused on Docker Containers, just copy it to destination path renaming as **automation_name.sh**.

This file is responsible for automations focused on Docker Containers or even for FliSys itself in manner to be more easily to do administration tasks, such as: docker images, containers deploys, version updates, etc.

## Templates not covered here

Do you know another use case that does not have a template?, or  
Do you want to improve the explanations in this page?  

You are welcome! Please, [Click here](https://github.com/mxfca/flisys/issues/new/choose) to request it.
