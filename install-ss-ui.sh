#!/bin/bash

# apt-get update

apt-get install net-tools
apt-get install iptables
apt-get install mosquitto
apt-get install libmosquitto1
apt-get install shadowsocks

wget -N https://raw.githubusercontent.com/MenglongWu/cloud-pub/master/deb/ss-ui.deb 
dpkg -i ss-ui.deb
