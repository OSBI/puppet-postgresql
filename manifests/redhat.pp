class postgresql::redhat inherits postgresql::base {

  include postgresql::params

  File[$postgresql::params::base_dir] {
    mode => '0700',
  }

  file {'/etc/sysconfig/pgsql':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    content => "PG_OOM_ADJ=${postgresql::params::oom_adj}\n",
  }

  postgresql::cluster {$postgresql::params::cluster_name:
    ensure  => present,
    version => $postgresql::params::version,
    require => Package['postgresql'],
  }

  service {'postgresql':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [
      Postgresql::Cluster[$postgresql::params::cluster_name],
      File['/etc/sysconfig/pgsql'],
    ]
  }

}
