/*

==Class: postgresql::debian::v8-4

Parameters:
 $postgresql_data_dir:
    set the data directory path, which is used to store all the databases

Requires:
 - Class["apt::preferences"]

*/
class postgresql::debian::v8-4 {

  $version = "8.4"

  case $lsbdistcodename {
    "lenny", "squeeze", "lucid", "natty" : {

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

      if $lsbdistcodename == "lenny" {
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

    }

    default: {
      fail "postgresql ${version} not available for ${operatingsystem}/${lsbdistcodename}"
    }
  }
}
