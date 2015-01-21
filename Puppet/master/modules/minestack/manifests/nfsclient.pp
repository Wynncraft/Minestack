class minestack::nfsclient($nfsserver = "nfs.internal.puppet") inherits minestack {

  file {"/mnt/minestack":
    ensure => directory,
  }

  mount {"/mnt/minestack":
    require => File['/mnt/minestack'],
    device => "${nfsserver}:/minestack",
    fstype => "nfs",
    ensure => "mounted",
    options => "ro",
    atboot => true,
  }

}