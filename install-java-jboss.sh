#!/bin/bash

mkdir -p /opt/products && mkdir -p /opt/appserver

# Download Java
wget -N https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz

# Extract Java
tar -zxvf OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz -C /opt/products

cd /opt/products && mv jdk8u352-b08 java

# Create Symbolic b/n JAVA directory
ln -s /opt/products/java /opt

# Set JAVA_HOME
export "export JAVA_HOME=/opt/java" >> /etc/profile

# Add JAVA_HOME/bin to PATH
export "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile

# Download WildFly
wget -N https://download.jboss.org/wildfly/24.0.0.Final/wildfly-24.0.0.Final.tar.gz

# Extract WildFly
tar -zxvf wildfly-24.0.0.Final.tar.gz -C /opt/products
cd /opt/products && mv wildfly-24.0.0.Final wildfly

# Create Symbolink b/n WILDFLY directory
ln -s /opt/products/wildfly  /opt/appserver

# Set WILDFLY_HOME
export WILDFLY_HOME=/opt/appserver/wildfly >> /etc/profile

# Add WILDFLY_HOME/bin to PATH
export PATH=$WILDFLY_HOME/bin:$PATH

# Create a Linux user and group to own WildFly software and processes.
groupadd -r nios
useradd -r -g nios -d /opt/appserver/wildfly -s /sbin/nologin nios

#Adjust ownership of extracted files as follows.
chown -RH nios: /opt/appserver/wildfly

#Create a directory for WildFly configuration files.
mkdir -p /etc/wildfly

# Configure wildfly service
cp /opt/appserver/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
cp /opt/appserver/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
cp /opt/appserver/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/appserver/wildfly/bin/

#Grant execution privileges on WildFly scripts.
chmod +x /opt/appserver/wildfly/bin/*.sh

#Enable and start WildFly service.
systemctl daemon-reload
systemctl enable --now wildfly.service

# Open linux firewall for wildfly and wildfly managment port
firewall-cmd --permanent --add-port={8080,9990}/tcp
firewall-cmd --reload

#Restart WildFly service to apply changes.
systemctl start wildfly.service
systemctl enable wildfly.service

# Info wildfly accessible on http://{ip}:8080