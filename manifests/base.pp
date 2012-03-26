/*

==Class: postgresql::base

This class is dedicated to the common parts 
shared by the different distributions

*/
class postgresql::base {

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

  # lens included upstream since augeas 0.7.4
  if versioncmp($augeasversion, '0.7.3') < 0 { $lens = present }
  else { $lens = absent }

  file { "/usr/share/augeas/lenses/contrib/pg_hba.aug":
    ensure => $lens,
    mode   => 0644,
    owner  => "root",
    source => "puppet:///modules/postgresql/pg_hba.aug",
  }

}
