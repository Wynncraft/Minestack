class minestack::ntpserver($clientsubnet = '172.16.0.0 mask 255.255.240.0') inherits minestack {
  class {'::ntp':
    restrict => ["${$clientsubnet} nomodify notrap"];
  }
}