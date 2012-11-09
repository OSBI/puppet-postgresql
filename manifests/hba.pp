/*
== Definition: postgresql::hba

Add/remove lines from pg_hba.conf file. NB: puppet reloads postgresql each time
a change is made to pg_hba.conf using this definition.

Parameters:
- *ensure*: present/absent, default to present.
- *type*: local/host/hostssl/hostnossl, mandatory.
- *database*: database name or "all", mandatory.
- *user*: username or "all", mandatory.
- *address*: CIDR or IP-address, mandatory if type is host/hostssl/hostnossl.
- *method*: auth-method, mandatory.
- *option*: optional additional auth-method parameter.
- *path*: path of the configuration file

See also:
http://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html

Example usage:

  postgresql::hba { "access to database toto":
    ensure   => present,
    type     => 'local',
    database => 'toto',
    user     => 'all',
    method   => 'ident',
    option   => "map=toto",
  }

  postgresql::hba { "access to database tata":
    ensure   => present,
    type     => 'hostssl',
    database => 'tata',
    user     => 'www-data',
    address  => '192.168.0.0/16',
    method   => 'md5',
  }

*/
define postgresql::hba (
  $type,
  $database,
  $user,
  $method,
  $ensure  = 'present',
  $address = false,
  $option  = false,
  $path    = false
) {

  include postgresql::params

  $target = $path ? {
    false   => $postgresql::params::pg_hba_conf_path,
    default => $path,
  }

  case $type {

    'local': {
      $changes = [ # warning: order matters !
        "set pg_hba.conf/01/type ${type}",
        "set pg_hba.conf/01/database ${database}",
        "set pg_hba.conf/01/user ${user}",
        "set pg_hba.conf/01/method ${method}",
      ]

      $xpath = "pg_hba.conf/*[type='${type}'][database='${database}'][user='${user}'][method='${method}']"
    }

    'host', 'hostssl', 'hostnossl': {
      if ! $address {
        fail("\$address parameter is mandatory for non-local hosts.")
      }

      $changes = [ # warning: order matters !
        "set pg_hba.conf/01/type ${type}",
        "set pg_hba.conf/01/database ${database}",
        "set pg_hba.conf/01/user ${user}",
        "set pg_hba.conf/01/address ${address}",
        "set pg_hba.conf/01/method ${method}",
      ]

      $xpath = "pg_hba.conf/*[type='${type}'][database='${database}'][user='${user}'][address='${address}'][method='${method}']"
    }

    default: {
      fail("Unknown type '${type}'.")
    }
  }

  case $ensure {

    'present': {
      augeas { "set pg_hba ${name}":
        context => "/files/${postgresql::params::conf_dir}/",
        incl    => "${postgresql::params::conf_dir}/pg_hba.conf",
        lens    => 'Pg_Hba.lns',
        changes => $changes,
        onlyif  => "match ${xpath} size == 0",
        notify  => Exec['reload_postgresql'],
        require => Package['postgresql'],
      }

      if $option {
        augeas { "add option to pg_hba ${name}":
          context => "/files/${postresql::params::conf_dir}/",
          incl    => "${postgresql::params::conf_dir}/pg_hba.conf",
          lens    => 'Pg_Hba.lns',
          changes => "set ${xpath}/method/option ${option}",
          onlyif  => "match ${xpath}/method/option size == 0",
          notify  => Exec['reload_postgresql'],
          require => Augeas["set pg_hba ${name}"],
        }
      }
    }

    'absent': {
      augeas { "remove pg_hba ${name}":
        context => "/files/${postgresql::params::conf_dir}/",
        incl    => "${postgresql::params::conf_dir}/pg_hba.conf",
        lens    => 'Pg_Hba.lns',
        changes => "rm ${xpath}",
        onlyif  => "match ${xpath} size == 1",
        notify  => Exec['reload_postgresql'],
        require => Package['postgresql'],
      }
    }

    default: {
      fail("Unknown ensure '${ensure}'.")
    }
  }

}

