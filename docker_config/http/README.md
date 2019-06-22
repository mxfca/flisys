# FliSys HTTP Service Docker

In this folder you will find all pre-defined configurations files for provisioning a new Docker Image of FliSys. This image is about the HTTP Service, you will need to create the database too.

## Pre requirements

- A machine running any Linux or Mac operating system
- Most recent version of Docker
- Bash shell version 3 or above
- An user that is able to handle docker commands without use sudo

## Step 01 - Set the execution permission

To start the process to generate a new Docker Image of Flisys HTTP Service, you'll need to set the execution permission on the script: *docker_config/scripts/create_http_image.sh*

```
$ chmod +x docker_config/scripts/create_http_image.sh
```

## Step 02 - Run the script

> **IMPORTANT**: You should run the script in the first level of directory tree, at /flisy

