#!/bin/bash

# apt-get update
# echo "deb https://mirrors.aliyun.com/ubuntu/ focal main multiverse restricted universe" > /etc/apt/sources.list.d/aliyun.list

apt-get install net-tools
apt-get install iptables
apt-get install mosquitto
apt-get install libmosquitto1
apt-get install shadowsocks-libev
apt-get install rsyslog

echo -e "\nkern.warning /var/log/iptables.log" >> /etc/rsyslog.d/50-default.conf

wget -N https://raw.githubusercontent.com/MenglongWu/cloud-pub/master/deb/ss-ui.deb 
dpkg -i ss-ui.deb


################################################

apt-get install nginx
apt-get install python3-pip
pip3 install Flask

