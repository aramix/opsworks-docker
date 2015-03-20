opsworks-docker
===============

## Forked from https://github.com/J-Katzen/opsworks-docker, this version does not support SSL


Make Docker go on Ops Works&lt;/pakled>

Based on [this AWS blog entry](http://blogs.aws.amazon.com/application-management/post/Tx2FPK7NJS5AQC5/Running-Docker-on-AWS-OpsWorks)

Instructions
================
1. Set up a new stack in Ops Works. Under Advanced set the following:
    * Chef version: 11.10
    * Use custom Chef cookbooks: https git url to this repo
    * Manage Berkshelf: Yes
    * Berkshelf version: 3.1.3
2. Add a layer
    * Type: Other
    * Recipes
        * Setup: owdocker::install
        * Deploy: owdocker::docker-image-deploy
        * Deploy: nginx-proxy::setup-nginx-proxy
        * Deploy: logspout::install
3. Add an App
    * Type: Other
    * Repository type: Other
    * Environment variables:
        * registry_image: The path portion of a docker pull command ala: docker pull {{ registry image }}
        * registry_tag: The tag of the image that should be pulled from the registry
        * layer: The shortname of the layer the image should be deployed to
        * service_port: The port on the HOST that will be connected to the container
        * container_port: The port on the CONTAINER that will be connected to the service port
        * registry_url: OPTIONAL url to a non hub.docker ala quay.io
        * registry_username: OPTIONAL username to login to the registry
        * registry_password: OPTIONAL password to login to the registry
        *
