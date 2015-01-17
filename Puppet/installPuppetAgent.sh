#!/bin/bash

service ntpd start
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install puppet
iptables -F
ip6tables -F
puppet agent -t