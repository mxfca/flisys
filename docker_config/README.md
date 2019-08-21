# FliSys Docker Container

In this section you will find all resources required to run FliSys in a Docker Container. You can use these containers for testing in your own machine (or notebook), proof of concepts or even put it in production in a dedicated server.

> IMPORTANT: if you do not have a dedicated server or already have a web server (shared hosting), you does not need nothing from this section.

## Pre Requirements

You'll need some installed packages in the machine you'll generate the Docker Containers, as follows:

  - Bash 4 or newer
  - OpenSSL
  - Systemctl
  - Docker
  - Docker Compose

## Step 01

Goes to _docker_config/scripts_ directory:

```
cd docker_config/scripts
```

Set execution permission only on main script:

```
chmod +x flisys_deploy.sh
```

## Step 02

Run the _flisys_deploy.sh_ passing the environment you want to deploy.

The supported environments are:

  - **Development**
    - Used by developers to create new features to FliSys, also can be used for testing purposes.
  - **Production**
    - This environment is used for a variety of purposes, such as: Quality Assurance (QA), Proof of Concept (POC) and Production itself.

```
./flisys_deploy.sh --environment=production
```

Now, just follow the steps and answer the questions when requested, once the process is done, you'll have a new FliSys environment deployed and already up & running.
