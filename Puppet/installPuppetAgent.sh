#!/bin/bash

rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install puppet
chkconfig puppet on
service puppet start