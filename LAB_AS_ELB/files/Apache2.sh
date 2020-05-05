#!/bin/bash
# Upodating the package lists
sudo apt-get update

#Apache2 installation
sudo apt-get install apache2 -y
sudo /etc/init.d/apache2 restart