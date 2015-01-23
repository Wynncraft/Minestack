class {'minestack':
  rsysloghost => 'syslog.internal.puppet',
  rsyslogport => '514',
}

node 'puppet.internal.puppet' {
  class {'minestack::ntpserver':
    clientsubnet => '172.16.0.0 mask 255.255.240.0',
  }
}

node 'nfs.internal.puppet' {
  class {'minestack::ntpclient':
    server => 'puppet.internal.puppet',
  }
  class {'minestack::nfsserver':
    clientsubnet => '172.16.0.0/12',
  }
}

node 'web.internal.puppet' {
  include minestack::web
}

node /^node(\d+)\.internal\.puppet$/ {
  class {'minestack::ntpclient':
    server => 'puppet.internal.puppet',
  }
  class {'minestack::nfsclient':
    nfsserver => 'puppet.internal.puppet',
  }
  class {'minestack::docker':
    dns => '172.16.0.1'
  }
  include minestack::docker
}
