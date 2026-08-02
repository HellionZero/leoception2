_This project has been created as part
of the 42 curriculum by **lsarraci.**_

# INCEPTION - USER GUIDE

## This document is intended to provide a guide for users who want to use the Inception project. It includes instructions for setting up the environment, using the application, and troubleshooting common issues.

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

with all the necessary packages installed, you can now configure the SSH server to start automatically when the virtual machine boots up. To do this, run the following command:
```
	systemctl enable ssh
```

Finally, you can test the SSH connection by connecting to the virtual machine from another computer using an SSH client such as PuTTY or the built-in SSH client in Linux or macOS. You will need to know the IP address of the virtual machine, which you can find by running the following command in the terminal:
```
	ip addr show
```

and on the other computer, you can connect to the virtual machine using the following command:
```
	ssh -i ~/.ssh/id_rsa your_username@ip_address
```

and with that, you should be able to connect to the virtual machine using SSH and start working on the Inception project.

