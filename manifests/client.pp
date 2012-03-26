/*

==Class: postgresql::client

Contains version-agnostig, distribution-agnostic installation of postgresql
client tools. This is useful to install tools such as psql and pg_dump on
machines which do not have the whole postgresql server suite installed.

*/

class postgresql::client {

  package { "postgresql-client":
    name   => $operatingsystem ? {
      /Debian|Ubuntu|kFreeBSD/ => 'postgresql-client',
      /RedHat|CentOS|Fedora/   => 'postgresql',
    },
    ensure => present,
  }

}
