class minestack::web inherits minestack {
  package {"webtatic-release-6-5.noarch":
    provider => rpm,
    source => "https://mirror.webtatic.com/yum/el6/latest.rpm",
    ensure => installed,
  }

  package {"git":
    ensure => installed,
  }

  package {"php55w":
    require => Package["webtatic-release-6-5.noarch"],
    ensure => installed,
  }

  package {"php55w-pear":
    require => Package["php55w"],
    ensure => installed,
  }

  package {"php55w-devel":
    require => Package["php55w"],
    ensure => installed,
  }

  package {"gcc":
    ensure => installed
  }

  exec {"php-mongo":
    require => [Package["gcc"], Package["php55w-pear"], Package["php55w-devel"]],
    command => "yes 'no' | pecl install mongo",
    path => ["/bin/", "/usr/bin/"],
    unless => 'pecl info mongo',
  }

  file { "/etc/php.d/mongo.ini":
    content=> 'extension=mongo.so',
    require => Exec["php-mongo"]
  }

  exec{"curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin":
    require => Package["php55w"],
    path => "/usr/bin/",
    creates => '/usr/bin/composer'
  }

  exec{"setsebool -P httpd_can_network_connect 1":
    path => "/usr/sbin/",
  }->
  vcsrepo { "/var/www/minestack":
    ensure   => present,
    provider => git,
    source   => "https://github.com/Minestack/CraftingTable.git",
  }->
  class {'apache':
    default_vhost => false
  }
  class {'::apache::mod::php':
    package_name => "php55w",
    path => "${::apache::params::lib_path}/libphp5.so",
  }
  apache::vhost{'minestack':
    port => '80',
    docroot => '/var/www/minestack/public',
    override => 'All',
    setenv => ["APP_ENV production"],
  }

  firewall {"005 accept http(s)":
    proto => 'tcp',
    port => [80, 443],
    state => ['NEW'],
    action => 'accept',
  }
}
