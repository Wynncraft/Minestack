node basenode {
        include epel

        class {'repo_elrepo':
                enable_elrepo => true,
                enable_kernel => true,
        }

        include repo_elrepo::kernel

        file {'/etc/sysconfig/kernel':
                owner => root,
                group => root,
                mode => 644,
                source => "puppet:///modules/minestack/sysconfig/kernel",
        }

        package {'kernel-lt':
                ensure => 'installed',
                #provider => 'linux',
        }

        #reboot {'after':
        #       subscribe => Package['kernel-lt'],
        #}

        class{'rsyslog::client':
                port => '514',
                remote_servers => [
                        {
                                host => 'logs2.papertrailapp.com',
                                port => '36317',
                                pattern => '*.*',
                                protocol => 'udp',
                        }
                ]
        }

        class {'rsyslog::server':}

        class {'firewall':}

        firewallchain {'OUTPUT:filter:IPv4':
                purge => true,
        }

        firewall {'000 accept all to lo interface':
                proto   => 'all',
                iniface => 'lo',
                action  => 'accept',
        }
        firewall { "001 reject local traffic not on loopback interface":
                iniface     => '! lo',
                proto       => 'all',
                destination => '127.0.0.1/8',
                action      => 'reject',
        }
        firewall {'002 accept related established rules':
                proto   => 'all',
                state => ['RELATED', 'ESTABLISHED'],
                action  => 'accept',
        }
        firewall {"003 accpt ssh":
                proto => 'tcp',
                port => 22,
                state => ['NEW'],
                action => 'accept',
        }
        firewall {"004 accept all from eth1":
                iniface => "eth1",
                proto => "all",
                state => ['NEW'],
                action => "accept",
        }
        firewall {"999 drop all":
                proto => "all",
                action => "drop",
        }
}

node 'puppet.internal.puppet' inherits basenode {
        class {'::ntp':
                restrict => ['172.16.0.0 mask 255.255.240.0 nomodify notrap'];
        }
}

node 'nfs.internal.puppet' inherits basenode {
        class {'::ntp':
                servers => ['puppet.internal.puppet'],
                restrict => ['127.0.0.1'],
        }

        file {"/minestack":
                ensure => directory,
        }

        file {"/mnt/minestack":
                ensure => directory,
        }

        include nfs::server
        nfs::server::export{'/minestack':
                ensure => 'mounted',
                clients => '172.16.0.0/16(ro,sync,no_root_squash,no_subtree_check) localhost(rw)',
                mount => '/mnt/minestack'
        }

        mount {"/mnt/minestack":
                device => "localhost:/minestack",
                fstype => "nfs",
                ensure => "mounted",
                options => "ro,auto,noatime,nolock,fg,nfsvers=3,intr,tcp,actimeo=1800",
                atboot => true,
        }
}

node /^node(\d+)\.internal\.puppet$/ inherits basenode {
        class {'::ntp':
                servers => ['puppet.internal.puppet'],
                restrict => ['127.0.0.1'],
        }

        file {"/mnt/minestack":
                ensure => directory,
        }

        mount {"/mnt/minestack":
                device => "nfs.internal.puppet:/minestack",
                fstype => "nfs",
                ensure => "mounted",
                options => "ro,auto,noatime,nolock,fg,nfsvers=3,intr,tcp,actimeo=1800",
                atboot => true,
        }

        file {"/tmp/minestack":
                ensure => directory,
        }

        file {"/tmp/minestack/docker":
                ensure => directory,
                recurse => remote ,
                source => "puppet:///modules/minestack/docker",
        }

        firewall {"005 accept all from docker0":
                iniface => "docker0",
                proto => "all",
                state => ['NEW'],
                action => "accept",
        }

        package {'docker-io':
                ensure => 'installed',
                install_options => ['--enablerepo=epel-testing'],
        }

        $nodeName = $trusted['certname']
        class {'docker':
                manage_package => false,
                tcp_bind => "tcp://$nodeName:4243",
                socket_bind => 'unix:///var/run/docker.sock',
                dns => '172.16.0.1',
        }

        docker::image{'minestack/bukkit':
                docker_dir => '/tmp/minestack/docker/bukkit',
        }

        docker::image{'minestack/bungee':
                docker_dir => '/tmp/minestack/docker/bungee',
        }
}