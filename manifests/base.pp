/*

==Class: postgresql::base

This class is dedicated to the common parts 
shared by the different distributions

*/
class postgresql::base {

  include postgresql::params

  user { "postgres":
    ensure  => present,
    require => Package["postgresql"],
  }

  package { "postgresql":
    name   => $operatingsystem ? {
      /Debian|Ubuntu|kFreeBSD/ => "postgresql",
      /RedHat|CentOS|Fedora/   => "postgresql-server",
    },
    ensure => present,
    notify => undef,
  }

  file {$postgresql::params::base_dir:
    ensure  => directory,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => undef,
    require => [Package['postgresql'], User['postgres']],
  }
  # lens included upstream since augeas 0.7.4
  if versioncmp($augeasversion, '0.7.3') < 0 { $lens_ensure = present }
  else { $lens_ensure = absent }

  augeas::lens { 'pg_hba':
    ensure      => $lens_ensure,
    lens_source => 'puppet:///modules/postgresql/pg_hba.aug',
  }

  exec {'reload_postgresql':
    refreshonly => true,
    command     => '/etc/init.d/postgresql reload',
  }

}
