/*

==Class: postgresql::debian::base

This class is dedicated to the common parts
shared by the different flavors of Debian

*/
class postgresql::debian::base inherits postgresql::base {

  include postgresql::params
  include postgresql::client

  Package["postgresql"] {
    name   => "postgresql-${version}",
    notify => Exec["drop initial cluster"],
  }

  package {[
    "postgresql-client-${version}",
    "postgresql-common",
    "postgresql-contrib-${version}"
    ]:
    ensure  => present,
    require => Package["postgresql"],
  }

  exec {"drop initial cluster":
    command     => "pg_dropcluster --stop ${version} main",
    onlyif      => "test \$(su -c 'psql -lx' postgres |awk '/Encoding/ {printf tolower(\$3)}') = 'sql_asciisql_asciisql_ascii'",
    timeout     => 60,
    environment => "PWD=/",
    before      => Postgresql::Cluster["main"],
  }

  postgresql::cluster {"main":
    ensure      => present,
    clustername => "main",
    version     => $version,
    encoding    => "UTF8",
    data_dir    => "${postgresql::params::data_dir}",
    require     => [Package["postgresql"], Exec["drop initial cluster"]],
  }

  Postgresql::Conf {
    pgver  => $version,
    before => Exec["drop initial cluster"],
  }

  # A few default postgresql settings without which pg_dropcluster can't run.
  postgresql::conf {
    'data_directory':        value => "/var/lib/postgresql/${version}/main";
    'hba_file':              value => "/etc/postgresql/${version}/main/pg_hba.conf";
    'ident_file':            value => "/etc/postgresql/${version}/main/pg_ident.conf";
    'external_pid_file':     value => "/var/run/postgresql/${version}-main.pid";
    'unix_socket_directory': value => '/var/run/postgresql';
    'ssl':                   value => 'true';
  }

}
