class postgresql::params {
  $postgresql_base_dir = "/mnt/postgresql"
  case $postgresql_version {
    '': {
      case $::operatingsystem {
        /^(RedHat|CentOS)$/ : {
          case $::lsbmajdistrelease {
            '6'    : { $version = '8.4' }
            default: { fail "${::lsbmajdistrelease} is not yet supported!" }
          }
        }
        /^(Debian|Ubuntu)$/ : {
          case $::lsbdistcodename {
            'lenny':   { $version = '8.3' }
            'squeeze': { $version = '8.4' }
            'lucid':   { $version = '8.4' }
            'precise': { $version = '9.1' }
            default:   { fail "${::operatingsystem} ${::lsbdistcodename} is not yet supported!"}
          }
        }
        default: { fail "${::operatingsystem} is not yet supported!" }
      }
    }
    /^(8.3|8.4|9.0|9.1)$/ : {
      case $::operatingsystem {
        /^(Debian|Ubuntu)$/ : {
          case $::lsbdistcodename {
            'lenny': {
              if $postgresql_version =~ /^(8.[34])$/ {
                $version = $postgresql_version
              } else {
                fail "version ${postgresql_version} is not supported for ${::operatingsystem} ${::lsbdistcodename}!"
              }
            }
            'squeeze': {
              if $postgresql_version =~ /^(8.4|9.0|9.1)$/ {
                $version = $postgresql_version
              } else {
                fail "version ${postgresql_version} is not supported for ${::operatingsystem} ${::lsbdistcodename}!"
              }
            }
            'lucid': {
              if $postgresql_version == '8.4' {
                $version = $postgresql_version
              } else {
                fail "version ${postgresql_version} is not supported for ${::operatingsystem} ${::lsbdistcodename}!"
              }
            }
            'precise': {
              if $postgresql_version == '9.1' {
                $version = $postgresql_version
              } else {
                fail "version ${postgresql_version} is not supported for ${::operatingsystem} ${::lsbdistcodename}!"
              }
            }
            default: { fail "${::operatingsystem} ${::lsbdistcodename} is not yet supported!" }
          }
        }
        default: { fail "${::operatingsystem} is not yet supported!" }
      }
    }
    default: { fail "PostgreSQL ${postgresql_version} is not supported by this module!" }
  }

  case $operatingsystem {
    /^(RedHat|CentOS)$/: {
      $oom_adj = $postgresql_oom_adj ? {
        ''      => 0,
        default => $postgresql_oom_adj,
      }
      $cluster_name = 'data'
      $base_dir = $postgresql_base_dir ? {
        ''      => '/var/lib/pgsql',
        default => $postgresql_base_dir,
      }
      $data_dir = "${base_dir}/${cluster_name}"
      $conf_dir = $data_dir
      $pg_hba_conf_path = "${conf_dir}/pg_hba.conf"
      $postgresql_conf_path = "${conf_dir}/postgresql.conf"
    }
    /^(Debian|Ubuntu)$/: {
      $cluster_name = 'main'
      $base_dir = $postgresql_base_dir ? {
        ''      => '/var/lib/postgresql',
        default => $postgresql_base_dir,
      }
      $data_dir = "${base_dir}/${version}/${cluster_name}"
      $conf_dir = "/etc/postgresql/${version}/${cluster_name}"
      $pg_hba_conf_path = "${conf_dir}/pg_hba.conf"
      $postgresql_conf_path = "${conf_dir}/postgresql.conf"
    }
    default: { fail "${::operatingsystem} is not yet supported!" }
  }

}
