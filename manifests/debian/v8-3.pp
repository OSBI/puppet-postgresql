/*

==Class: postgresql::debian::v8-3

Parameters:
 $postgresql_data_dir:
   set the data directory path, which is used to store all the databases

Requires:
 - Class["apt::preferences"]

*/
class postgresql::debian::v8-3 {

  $version = "8.3"

  case $lsbdistcodename {
    "lenny" : {
      
      include postgresql::debian::base

      service {"postgresql":
        name      => "postgresql-${version}",
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => Package["postgresql"],
      }

      exec { "reload postgresql ${version}":
        refreshonly => true,
        command     => "/etc/init.d/postgresql-${version} reload",
      }

    }
    default: {
      fail "postgresql ${version} not available for ${operatingsystem}/${lsbdistcodename}"
    }
  }

}
