class minestack::ntpclient($server = 'puppet.internal.puppet') inherits minestack {
  class {'::ntp':
    servers => [$server],
    restrict => ['127.0.0.1'],
  }
}