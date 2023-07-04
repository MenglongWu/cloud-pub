#!/bin/bash

# apt-get update
# echo "deb https://mirrors.aliyun.com/ubuntu/ focal main multiverse restricted universe" > /etc/apt/sources.list.d/aliyun.list

apt-get -y  install net-tools
apt-get -y  install iptables
apt-get -y  install mosquitto
apt-get -y  install libmosquitto1
apt-get -y  install shadowsocks-libev
apt-get -y  install rsyslog

echo -e "\nkern.warning /var/log/iptables.log" >> /etc/rsyslog.d/50-default.conf

wget -N https://raw.githubusercontent.com/MenglongWu/cloud-pub/master/deb/ss-ui.deb 
dpkg -i ss-ui.deb


################################################

# apt-get -y install nginx
apt-get -y install python3
apt-get -y install python3-flask

# apt-get -y install python3-pip
# pip3 install Flask

