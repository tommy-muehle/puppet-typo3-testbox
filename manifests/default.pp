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
  version => '6.1.7',
  site_path => '/var/www/test',
  site_user => 'vagrant',
  site_group => 'www-data',
  require => Apache::Vhost['test.typo3.local'],
  use_symlink => false,
  db_name => 'test',
  db_host => 'localhost',
  db_pass => '',
  db_user => 'root',
  local_conf => {
      'sys' => {
         'encryptionKey' => '47ac9add3f53f8464d33ee5785a2f25dc35e8da9fcea8bbc41eb9ced5f58574f326abcecf1924b5ab0d3229c038d7c37',
      },
      'be' => {
         'installToolPassword' => 'bacb98acf97e0b6112b1d1b650b84971',
      },
  },
  extensions => [
      {"key" => "realurl", "repo" => "git://git.typo3.org/TYPO3CMS/Extensions/realurl.git", "tag" => "1_12_6"},
      {"key" => "phpunit", "repo" => "git://git.typo3.org/TYPO3CMS/Extensions/phpunit.git"}
  ]
}