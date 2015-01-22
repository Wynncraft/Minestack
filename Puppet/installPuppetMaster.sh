#!/bin/bash

rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install puppet-server
cp master/puppet.conf /etc/puppet/puppet.conf
puppet master --verbose --no-daemonize
chkconfig puppetmaster on
service puppetmaster start