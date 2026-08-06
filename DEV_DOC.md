_This project has been created as part
of the 42 curriculum by **lsarraci.**_

# INCEPTION - DEVELOPER GUIDE

## This document is intended to provide a guide for developers who want to use the Inception project. It includes instructions for setting up the environment, using the application, and troubleshooting common issues.

1) Setting up the environment

table of contents:

- [Preparing the virtual machine](#preparing-the-virtual-machine)
- [Installing Docker and Docker Compose](#installing-docker-and-docker-compose)
- [Organizing the project files](#organizing-the-project-files)
- [Setting up the database](#setting-up-the-database)
- [Setting up the WordPress CMS](#setting-up-the-wordpress-cms)
- [Setting up the NGINX web server](#setting-up-the-nginx-web-server)

### Preparing the virtual machine

To prepare the virtual machine, you will need to follow these steps:
- Download and install a virtualization software such as VirtualBox or VMware on your computer.
- For this project, we will using VirtualBox. You can download it from the official website: https://www.virtualbox.org/wiki/Downloads
- The next step is to download the virtual machine image. This project use the last stable release of Debian 13(trixie). You can download it from the official website: https://www.debian.org/distrib/netinst
- Create a new virtual machine in VirtualBox and configure it with the following settings:
  - Name: Inception
  - Type: Linux
  - Version: Debian (64-bit)
  - Memory size: 2048 MB
  - Hard disk: Create a virtual hard disk now (VDI, dynamically allocated, 20 GB)
- Once the virtual machine is created, start it and follow the installation process for Debian 13. you can use the default settings for most of the installation steps, but make sure to set a strong password for the root user and create a new user account for yourself.
- You can utilize GNOME or XFCE as a desktop environment, but for this project, we will be using GNOME. You can select it during the installation process or install it later using the command line.
- with the operating system up and running, the next step is to install the sudo package. This package allows you to run commands with administrative privileges, which is necessary for installing and configuring software on the system. To install sudo, open a terminal and run the following command:

```
	apt-get update && apt-get install sudo
```

and you need to log in as the root user to add the user to the sudo group by running the following commands:
```
	su -
	usermod -aG sudo your_username
```
- optionally, you can also install the `vim` text editor, which is a powerful and widely used text editor in the Linux environment. To install `vim`, run the following command:
```
	apt-get install vim
```

The next part is to install the SSH server, which allows you to remotely access the virtual machine from another computer. You need to install the `openssh-server` package, which provides the necessary components for running an SSH server on the system, and the `ufw` package, which is a firewall management tool that allows you to configure and manage the firewall rules on the system. To install these packages, run the following command:

```bash
	apt-get install openssh-server ufw
```

Now we need to configure the port forwarding in the terminal. first we need to check the status of the ssh service by running the following command:

```bash
	sudo service ssh status
```

once you have verified the status of the SSH service, we need to modify the `/etc/ssh/sshd_config` file to change the default port number for SSH connections. You can do this by running the following command:

```bash
	sudo vim /etc/ssh/sshd_config
```

and change the line that says `#Port 22` to `Port 4242`. This will change the default port number for SSH connections to 4242. After making this change, save the file and exit the text editor. we also need to set the `PermitRootLogin` option to `no` in the same file. This will disable root login via SSH, which is a security best practice. To do this, find the line that says `#PermitRootLogin prohibit-password` and change it to `PermitRootLogin no`.
We also need to alter the file `/etc/ssh/ssh_config` to change the default port number for SSH connections. You can do this by running the following command:
```
	sudo vim /etc/ssh/ssh_config
```
and change the line that says `#Port 22` to `Port 4242`, save it and exit the text editor. This will change the default port number for SSH connections to 4242 for outgoing connections as well. once you have made these changes, save the file and exit the text editor. Finally, we need to restart the SSH service to apply the changes we made to the configuration file. You can do this by running the following command:

```bash
	sudo service ssh restart
```

The next step is to allow the virtual machine from the outside. First, turn off the VM and go to settings-> network->advanced->port forwarding. Add a new rule with the following settings:
- Name: SSH
- Protocol: TCP
- Host IP:
- Host Port: 4242
- Guest IP:
- Guest Port: 4242 (if somehow the connections are not working, you can try changing the guest port to 4241 or 4243, but make sure to update the SSH configuration files accordingly)

and to access the virtual machine from the host machine, you can use the following command:
```bash
	ssh < your_username >@localhost -p 4242 
```
(or 4241 or 4243 if you changed the guest port)

Remember to ensure the firewall is configured to allow incoming connections on the SSH port. You can do this by running the following commands:
```bash
	sudo ufw allow 4242/tcp
	sudo ufw enable
```

the next step is to install the `curl` command-line tool, which is used to transfer data from or to a server. To install `curl`, run the following command:

```
	apt-get install curl
```
this command will install the `curl` package and its dependencies on the system. Once the installation is complete, you can verify that `curl` is installed by running the following command:
```
	curl --version
```
once you have verified that `curl` is installed, you can use it to download files from the internet or test API endpoints. For example, you can use the following command to download a file from a URL. This will be useful to download the Docker installation script in the next step.

## Installing Docker and Docker Compose

To install Docker and Docker Compose, you will need to follow these steps:
- First, you need to update the package index and install the required packages for Docker. You can do this by running the following command:
```
	apt-get update && apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
```
- Next, you need to add the Docker GPG key and repository. You can do this by running the following commands:
```
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
```
this will allow the debian package manager to download and install Docker from the official Docker repository.
- After adding the Docker repository, you need to update the package index again and install Docker. You can do this by running the following command:
```
	apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
- Once Docker is installed, you can verify that it is working by running the following command:
```
	docker --version
```
- Once Docker Compose is installed, you can verify that it is working by running the following command:
```
	docker compose version
```
if everything is working correctly, you should see the version numbers for both Docker and Docker Compose displayed in the terminal. now, for the final step, you need to add your user to the Docker group. This will allow you to run Docker commands without using `sudo`. You can do this by running the following command:
```
	usermod -aG docker your_username
```
with all of this, the next step is to use a simple script to check if Docker and Docker Compose are installed correctly. You can create a new file called `docker_test.sh` and add the following code to it:
```
	#!/bin/bash
	docker run hello-world
	docker compose version
```
then, make the script executable by running the following command:

```bash
	chmod +x docker_test.sh
```
finally, run the script by executing the following command:

```bash
	./docker_test.sh
```
if everything is working correctly, you should see a message from Docker indicating that the installation was successful. This means that Docker and Docker Compose are installed and working correctly on your system, and you are ready to start using them for your Inception project.

## Organizing the project files

This is the trickiest part, as it requires you to create a specific directory structure for the project files. You will need to create a new directory called `inception` in your home directory, and then create the following subdirectories inside it:

```
	inception/
	├── secrets/
	├── srcs/
	|	  ├──── requirements
	|	  |			├──	nginx/
	|	  |			├──	wordpress/
	|	  |			├──	mariadb/
	|	  |			└──	other_services/
	|	  ├── docker-compose.yml
	|	  └──.env
	└──	Makefile
```

## setting up the database

As the backbone of the project, MariaDB must be installed first. It is a popular open-source relational database management system that is used to store and manage data for web applications. In this project, MariaDB will be used to store the data for the WordPress CMS and other services that may be added in the future. By installing MariaDB first, you can ensure that the database is set up and ready to use before installing the other services that depend on it.

In this project, we will set up MariaDB using Docker Compose and custom configuration files. The configuration files will be stored in the `srcs/requirements/mariadb/` directory, and will include a `Dockerfile`, a `my.cnf` file for custom configuration, and an `init_db.sh_` file for initializing the database with the necessary tables and data, utilizing the secrets stored in the `secrets/` directory. The `docker-compose.yml` file will define the MariaDB service and its dependencies, and will be used to start and stop the service as needed.
To ensure that the mariaDB service is running correctly, we will also include a `healthcheck` in the `docker-compose.yml` file. This will allow us to monitor the status of the service and ensure that it is functioning properly. As an extra step, we will set the `health_user` and `health_password` environment variables in the `docker-compose.yml` file, which will be used to authenticate the health check requests. This will help to ensure that the service is secure and that only authorized users can access it.

we need to set up the dockerfile first, as we cannot rely on the official MariaDB image to have the necessary configuration for our project. The Dockerfile will be used to build a custom image for the MariaDB service, which will include the necessary configuration files and scripts for initializing the database.

The Dockerfile will be stored in the `srcs/requirements/mariadb/` directory, and will be based on the alpine Linux image, which is a lightweight and secure Linux distribution that is ideal for running Docker containers. The Dockerfile will include the necessary commands to copy the configuration files and scripts into the container, set the appropriate permissions, and start the MariaDB service.

```Dockerfile
	#current stable version of alpine
	FROM alpine:3.23

	# install mariadb and mariadb-client with gettext for envsubst command (for future uses), with the option --no-cache to avoid caching the package index and reduce the size of the image.
	RUN apk update && apk add --no-cache mariadb mariadb-client gettext

	#create the directories for the MariaDB data and runtime files, and set the appropriate ownership and permissions for the mysql user and group.
	RUN mkdir -p /run/mysqld /var/lib/mysql 
	RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

	#copy the custom configuration file for MariaDB into the container, and set the appropriate ownership and permissions for the mysql user and group.
	COPY conf/my.cnf /etc/mysql/my.cnf
	RUN chmod 644 /etc/mysql/my.cnf \
		&& chown mysql:mysql /etc/mysql/my.cnf

	#copy the script for initializing the database into the container, and set the appropriate ownership and permissions for the mysql user and group.
	COPY tools/init_db.sh /init_db.sh
	RUN chmod +x /init_db.sh

	#expose the default port for MariaDB, which is 3306, to allow incoming connections from other services and applications.
	EXPOSE 3306

	#set the entrypoint for the container to the init_db.sh script to initialize the database when the container is started.
	ENTRYPOINT ["/init_db.sh"]
```

the `my.cnf` file will be used to configure the MariaDB service, and will include settings for the database server, such as the port number, data directory, and other options. The my.cnf file will be stored in the `srcs/requirements/mariadb/conf/` directory, and will be copied into the container during the build process.

the `init_db.sh` file will be used to initialize the database with the necessary tables and data, utilizing the secrets stored in the `secrets/` directory. This script will be executed on the start of the container and will create the necessary data to run the service accordingly. The init_db.sh file will be stored in the `srcs/requirements/mariadb/tools/` directory, and will be copied into the container during the build process. The `init_db.sh` is documented and commented to explain the purpose of each command and how it works. This will help other developers understand the script and make modifications if necessary.

With the Dockerfile, my.cnf, and init_db.sh files in place, we can now define the MariaDB service in the `docker-compose.yml` file. The docker-compose.yml file will be stored in the `srcs/` directory, and will include the necessary configuration for the MariaDB service, such as the image name, container name, environment variables, ports, volumes, and health check.

```yaml
	#we need to define the network to be used by the services, in this case we will use a bridge network called "inception". This will allow the containers to communicate with each other and with the host system.
	networks:
	inception:
		driver: bridge

	#we also need to define the volumes to be used by the services, in this case we will use two named volumes called "mariadb_data" and "wp_data". This will allow the containers to persist data even if they are stopped or removed.
	volumes:
  		mariadb_data:
  		wp_data:

	#secrets are important resources to store sensitive information as passwords and API keys. The secrets are stored in the `secrets/` directory, and will be mounted into the containers as read-only files. This will allow the containers to access the secrets without exposing them to other services or users.
	secrets:
		db_root_password:
			file: ../secrets/db_root_password
		db_health_user:
			file: ../secrets/db_health_user
		db_health_password:
			file: ../secrets/db_health_password
		wp_db_name:
			file: ../secrets/wp_db_name
		wp_db_user:
			file: ../secrets/wp_db_user
		wp_db_password:
			file: ../secrets/wp_db_password
		wp_user:
			file: ../secrets/wp_user
		wp_user_password:
			file: ../secrets/wp_user_password
		wp_user_email:
			file: ../secrets/wp_user_email
		wp_admin_password:
			file: ../secrets/wp_admin_password
		wp_admin_email:
			file: ../secrets/wp_admin_email

	services:
		mariadb:
			build: ./requirements/mariadb
			container_name: mariadb
			restart: unless-stopped
			env_file:
			- temp.env
			ports:
			- 3306:3306
			volumes:
			- mariadb_data:/var/lib/mysql
			healthcheck:
			#we need to execute a health check to verify the status of the MariaDB service to ensure the service is running correctly and can accept connections. This measure is important for mantaining the avaliability and reliability of the service, as it allows us to detect and respond to issues before they affect the other services that depend on it.
			test:
				[
				"CMD-SHELL",
				"mariadb-admin ping -h localhost -u $(cat /run/secrets/db_health_user) -p$(cat /run/secrets/db_health_password) || exit 1",
				]
			interval: 10s
			timeout: 5s
			retries: 5
			start_period: 20s
			networks:
			- inception
			secrets:
			- db_root_password
			- db_health_user
			- db_health_password
			- wp_db_name
			- wp_db_password
			- wp_db_user
```

with all those steps, the MariaDB service should be set up and ready to use. You can start the service by running the following command in the `srcs/` directory:

```bash
	docker compose up -d mariadb
```

It can take a few seconds for the service to start up and become healthy. You can check the status of the service by running the following command:

```bash
	docker compose ps
```

## setting up the WordPress CMS

Once the database is up and running, we can proceed to set up the WordPress CMS. As the same as the MariaDB service, we will set up WordPress using Docker Compose and custom configuration files. Inside the `srcs/requirements/wordpress/` directory, we will create a `Dockerfile` with the following instructions:

```Dockerfile
	FROM alpine:3.23

	#we need to install all the necessary packages for running WordPress, including PHP and its extensions, the MariaDB client, and wget for downloading files. We will use the `apk` package manager to install these packages, with the option `--no-cache` to avoid caching the package index and reduce the size of the image.
	RUN apk update && apk add --no-cache \
		php-fpm \
		php-iconv \
		php-mbstring \
		php-tokenizer \
		php-mysqli \
		php-json \
		php-curl \
		php-opcache \
		php-xml \
		php-phar \
		php-zip \
		php-session \
		mariadb-client \
		wget
	
	#we need to create the directory for the PHP runtime files, and set the appropriate ownership and permissions for the `www-data` user and group.
	RUN mkdir -p /run/php

	RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
		chmod +x /usr/local/bin/wp

	COPY ./tools/*.sh /usr/local/bin/
	RUN chmod +x /usr/local/bin/init_wp.sh

	#we need to set the working directory for the container to `/var/www/html`, which is the default document root for the NGINX web server. This will allow us to serve the WordPress files from this directory.
	WORKDIR /var/www/html

	#we need to expose the port 5050 for the WordPress service. later we will change to the port 9000 for the PHP-FPM service to be used by the NGINX web server. The port 5050 is used for testing purposes and can be changed to any other available port if needed.
	EXPOSE 5050

	#the entrypoint for the container is set to the `init_wp.sh` script, which will be executed when the container is started. This script will initialize the WordPress installation and configure it to connect to the MariaDB database using the secrets stored in the `secrets/` directory.
	ENTRYPOINT ["/usr/local/bin/init_wp.sh"]
```

And finally we need to set up the service in the `docker-compose.yml` file, which will define the WordPress service and its dependencies, such as the MariaDB service and the NGINX web server. The WordPress service will be configured to use the custom image built from the Dockerfile, and will be connected to the `inception` network and the `wp_data` volume for persisting data.

```yaml
	wordpress:
		build: ./requirements/wordpress
		container_name: wordpress
		restart: unless-stopped
		env_file:
		- temp.env
		ports:
		- 5050:5050
		volumes:
		- wp_data:/var/www/html
		depends_on:
			mariadb:
				condition: service_healthy
		networks:
			- inception
		secrets:
			- wp_db_name
			- wp_db_user
			- wp_db_password
			- wp_user
			- wp_user_password
			- wp_user_email
			- wp_admin_password
			- wp_admin_email
```

once we enter the srcs/ directory, we can start the WordPress service by running the following command:

```bash
	docker compose up -d wordpress
```

we can navigate to the WordPress installation page by opening a web browser and entering the following URL:

```
	http://localhost:5050
```

## setting up the NGINX web server

this is the most critical part of the project, as we need to make sure the NGINX web server is the only way to access the entire project, with all the security configurations to access the services with the correct credentials. The NGINX web server will be set up using Docker Compose and custom configuration files, similar to the MariaDB and WordPress services. The configuration files will be stored in the `srcs/requirements/nginx/` directory, and will include a `Dockerfile`, a `nginx.conf` file for custom configuration, and a `default.conf` file for defining the virtual host.