/*

==Class: postgresql::debian::v9-1

Parameters:
 $postgresql_data_dir:
    set the data directory path, which is used to store all the databases

Requires:
 - Class["apt::preferences"]

*/
class postgresql::debian::v9-1 {

  $version = "9.1"

  case $lsbdistcodename {
    squeeze: {

      include postgresql::debian::base

      service {"postgresql":
        ensure    => running,
        enable    => true,
        hasstatus => true,
        start     => "/etc/init.d/postgresql start ${version}",
        status    => "/etc/init.d/postgresql status ${version}",
        stop      => "/etc/init.d/postgresql stop ${version}",
        restart   => "/etc/init.d/postgresql restart ${version}",
        require   => Package["postgresql-common"],
      }

      exec { "reload postgresql ${version}":
        refreshonly => true,
        command     => "/etc/init.d/postgresql reload ${version}",
      }

      apt::preferences {[
        "libpq5",
        "postgresql-${version}",
        "postgresql-client-${version}",
        "postgresql-common",
        "postgresql-client-common",
        "postgresql-contrib-${version}"
        ]:
        pin      => "release a=${lsbdistcodename}-backports",
        priority => "1100",
      }
    }

    default: {
      fail "${name} not available for ${operatingsystem}/${lsbdistcodename}"
    }
  }
}
