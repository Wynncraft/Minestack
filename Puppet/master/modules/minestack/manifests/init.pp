class minestack($rsysloghost = 'localhost', $rsyslogport = '514') {

  $remoteHost = "*.*          @${$rsysloghost}:${$rsyslogport}"
  include epel

  class {'repo_elrepo':
    enable_elrepo => true,
    enable_kernel => true,
  }->
  class {'repo_elrepo::kernel': }->
  file {'/etc/sysconfig/kernel':
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/minestack/sysconfig/kernel",
  }->
  package {'kernel-lt':
    ensure => 'installed',
    #provider => 'linux',
  }

  #reboot {'after':
  #       subscribe => Package['kernel-lt'],
  #}

  class{'rsyslog::client':
    log_local => true,
    port => '514',
    remote_servers => [
      {
        host => $rsysloghost,
        port => $rsyslogport,
        pattern => '*.*',
        protocol => 'udp',
      }
    ]
  }

  class {'rsyslog::server':
    server_dir => $remoteHost,
    custom_config => 'rsyslog/rsyslog.erb'
  }

  class { 'fail2ban': }

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
