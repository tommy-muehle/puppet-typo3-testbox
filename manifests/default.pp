# DEFAULTS
group { 'puppet': ensure => present}
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ]}
File { owner => 0, group => 0, mode => 0644}

# SYSTEM
class { 'apt':
  always_apt_update => true,
}

apt::source { 'dotdeb':
  location          => 'http://packages.dotdeb.org/',
  release           => 'wheezy',
  repos             => 'all',
  key               => '89DF5277',
  key_server        => 'keys.gnupg.net',
  pin               => '-10',
  include_src       => true
}

package {[
    'build-essential',
    'vim',
    'curl',
    'git-core'
  ]:
  ensure  => 'installed',
}

# APACHE
class { 'apache': }
apache::module { 'rewrite': }

# MYSQL
class { 'mysql::server':
  override_options => { 'root_password' => '', },
}

# PHP
class { 'php':
  service             => 'apache',
  service_autorestart => false,
  module_prefix       => '',
}
php::module { 'php5-mysql': require => Class['php'] }
php::module { 'php5-cli': require => Class['php'] }
php::module { 'php5-curl': require => Class['php'] }

# PROJECT
apache::vhost { 'test.typo3.local':
  server_name   => 'test.typo3.local',
  serveraliases => '',
  docroot       => '/var/www/test',
  port          => '80',
}

mysql_database { 'test':
  ensure  => present,
  charset => 'utf8',
  require => Class['mysql::server'],
}

typo3::project { 'test':
  version => '6.1.3',
  site_path => '/var/www/test',
  site_user => 'vagrant',
  site_group => 'www-data',
}