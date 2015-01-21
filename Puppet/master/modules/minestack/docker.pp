class minestack::docker inherits minestack {

  firewall {"005 accept all from docker0":
    iniface => "docker0",
    proto => "all",
    state => ['NEW'],
    action => "accept",
  }

  package {'docker-io':
    require => [Yumrepo['epel'], Yumrepo['epel-testing']],
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
  }

  docker::image{'minestack/bungee':
  }

}