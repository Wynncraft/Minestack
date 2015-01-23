class minestack::nfsclient($nfsserver = "nfs.internal.puppet") inherits minestack {

  file {"/mnt/minestack":
    ensure => directory,
  }->
  package {['nfs-utils', 'nfs-utils-lib']:
    ensure => 'installed'
  }->
  mount {"/mnt/minestack":
    device => "${nfsserver}:/minestack",
    fstype => "nfs",
    ensure => "mounted",
    options => "ro",
    atboot => true,
  }

}