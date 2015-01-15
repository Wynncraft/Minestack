#!/bin/bash

puppet module install garethr-docker
puppet module install puppetlabs-firewall
puppet module install puppetlabs-ntp
puppet module install puppetlabs-reboot
puppet module install flakrat-repo_elrepo
puppet module install saz-rsyslog
puppet module install haraldsk-nfs