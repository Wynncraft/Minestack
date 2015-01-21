class minestack::nfsserver($clientsubnet = '172.16.0.0/16') inherits minestack {
  file {"/minestack":
    ensure => directory,
  }

  file {"/mnt/minestack":
    ensure => directory,
  }

  include nfs::server
  nfs::server::export{'/minestack':
    require => File['/minestack'],
    ensure => 'mounted',
    clients => "${$clientsubnet}(ro,sync,no_root_squash,no_subtree_check) localhost(rw)",
    mount => '/mnt/minestack'
  }

  mount {"/mnt/minestack":
    require => File['/mnt/minestack'],
    device => "localhost:/minestack",
    fstype => "nfs",
    ensure => "mounted",
    options => "ro",
    atboot => true,
  }
}