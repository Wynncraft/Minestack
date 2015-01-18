#!/bin/bash

yum install named
cp named.conf /etc/named.conf
cp 172.16.0.zone /var/named/172.16.0.zone
cp internal.puppet.zone /var/named/internal.puppet.zone