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

the next part is to install the SSH server, which allows you to remotely access the virtual machine from another computer. To install the SSH server, run the following command:
```
	apt-get install openssh-server
```

to verify that the SSH server is running, you can use the following command:
```
	systemctl status ssh
```

and you need to specify the port number for the SSH server to listen on. By default, the SSH server listens on port 22, but you can change it to a different port if you prefer. To do this, edit the SSH configuration file using the following command:
```
	vim /etc/ssh/sshd_config
```

and you need to set a file to `Port 22` in the configuration file.

Change the `Port` line to the desired port number.

the next step is to configure the firewall to allow incoming SSH connections. You can use the `ufw` firewall to do this. To install `ufw`, run the following command:
```
	apt-get install ufw
```

and to use ufw without the sudo command, you need to add your user to the `sudo` group. You can do this by running the following command:
```
	usermod -aG sudo your_username
```
Then, enable the firewall and allow incoming SSH connections on the specified port using the following commands:
```
	sudo ufw enable
	sudo ufw allow your_port_number/tcp
```

next, you need to find the IP address of the virtual machine. You can do this by running the following command:
```
	ip addr show
```

and search for the `inet` line under the network interface that is connected to the internet. The IP address will be listed next to it.
to connect to the virtual machine using SSH, you will need to use an SSH client on your local machine. If you are using a Linux or macOS system, you can use the built-in terminal. If you are using Windows, you can use an SSH client such as PuTTY.
To connect to the virtual machine, open the terminal or SSH client and run the following command:
```
	ssh your_username@your_ip_address -p your_port_number
```

and with that, you should be able to connect to the virtual machine using SSH and start working on the Inception project.

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

### order of installation of the services

1) MariaDB

As the backbone of the project, MariaDB must be installed first. It is a popular open-source relational database management system that is used to store and manage data for web applications. In this project, MariaDB will be used to store the data for the WordPress CMS and other services that may be added in the future. By installing MariaDB first, you can ensure that the database is set up and ready to use before installing the other services that depend on it.

In this project, we will set up MariaDB using Docker Compose and custom configuration files. The configuration files will be stored in the `srcs/requirements/mariadb/` directory, and will include a `Dockerfile`, a `my.cnf` file for custom configuration, and an `init_db.sh_` file for initializing the database with the necessary tables and data, utilizing the secrets stored in the `secrets/` directory. The `docker-compose.yml` file will define the MariaDB service and its dependencies, and will be used to start and stop the service as needed.
To ensure that the mariaDB service is running correctly, we will also include a `healthcheck` in the `docker-compose.yml` file. This will allow us to monitor the status of the service and ensure that it is functioning properly. As an extra step, we will set the `health_user` and `health_password` environment variables in the `docker-compose.yml` file, which will be used to authenticate the health check requests. This will help to ensure that the service is secure and that only authorized users can access it.

we need to set up the dockerfile first, as we cannot rely on the official MariaDB image to have the necessary configuration for our project. The Dockerfile will be used to build a custom image for the MariaDB service, which will include the necessary configuration files and scripts for initializing the database.

The Dockerfile will be stored in the `srcs/requirements/mariadb/` directory, and will be based on the alpine Linux image, which is a lightweight and secure Linux distribution that is ideal for running Docker containers. The Dockerfile will include the necessary commands to copy the configuration files and scripts into the container, set the appropriate permissions, and start the MariaDB service.