#!/bin/bash

puppet module install puppetlabs-apache
puppet module install garethr-docker
puppet module install puppetlabs-firewall
puppet module install puppetlabs-ntp
puppet module install puppetlabs-reboot
puppet module install flakrat-repo_elrepo
puppet module install saz-rsyslog
puppet module install echocat-nfs
puppet module install puppetlabs-vcsrepo
puppet module install netmanagers-fail2ban
cp -R master/modules/minestack /etc/puppet/modules/minestack
cp -R master/modules/rsyslog /etc/puppet/modules/rsyslog
