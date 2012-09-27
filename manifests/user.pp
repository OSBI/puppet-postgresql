/*

==Definition: postgresql::user

Create a new PostgreSQL user

*/
define postgresql::user(
  $ensure=present, 
  $password=false, 
  $superuser=false,
  $createdb=false,
  $createrole=false,
  $hostname='/var/run/postgresql', 
  $port='5432', 
  $user='postgres') {

  $pgpass = $password ? {
    false   => "",
    default => "$password",
  }

  # Connection string
  $connection = "-h ${hostname} -p ${port} -U ${user}"

  # Quite aweful 0.25.x backward compatibility hack, used only in the file
  # definition below and will be removed as soon as possible
  if $module_name == '' {
    $module_name = "postgresql"
  }

  # Script we use to manage postgresql users
  if ! defined( File ['/usr/local/sbin/pp-postgresql-user.sh'] ) {
    file { '/usr/local/sbin/pp-postgresql-user.sh':
      ensure => present,
      source => "puppet:///modules/${module_name}/pp-postgresql-user.sh",
      mode   => 0755,
    }
  }

  case $ensure {
    present: {

      # The createuser command always prompts for the password.
      # User with '-' like www-data must be inside double quotes
      exec { "Create postgres user $name":
        command => $password ? {
          false => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' createusernopwd '${name}'",
          default => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' createuser '${name}' '${password}' ",
        },
        user    => "postgres",
        unless  => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' checkuser '${name}'",
        require => Postgresql::Cluster["main"],
      }

      exec { "Set SUPERUSER attribute for postgres user $name":
        command => inline_template("/usr/local/sbin/pp-postgresql-user.sh '<%= connection %>' setuserrole '<%= name %>' '<%= superuser ? '':'NO' %>SUPERUSER'"),
        user    => "postgres",
        unless  => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' checkuserrole '${name}' '$superuser' rolsuper",
        require => Exec["Create postgres user $name"],
      }

      exec { "Set CREATEDB attribute for postgres user $name":
        command => inline_template("/usr/local/sbin/pp-postgresql-user.sh '<%= connection %>' setuserrole '<%= name %>' '<%= createdb ? '':'NO' %>CREATEDB'"),
        user    => "postgres",
        unless  => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' checkuserrole '${name}' '$createdb' rolcreatedb",
        require => Exec["Create postgres user $name"],
      }

      exec { "Set CREATEROLE attribute for postgres user $name":
        command => inline_template("/usr/local/sbin/pp-postgresql-user.sh '<%= connection %>' setuserrole '<%= name %>' '<%= createrole ? '':'NO' %>CREATEROLE'"),
        user    => "postgres",
        unless  => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' checkuserrole '${name}' '$createrole' rolcreaterole",
        require => Exec["Create postgres user $name"],
      }

      if $password {
        $host = $hostname ? {
          '/var/run/postgresql' => "localhost",
          default               => $hostname,
        }

        # change only if it's not the same password
        exec { "Change password for postgres user $name":
          command => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' setpwd '${name}' '${pgpass}' && echo '${pgpass}' > /root/.pgpassword",
          user    => "postgres",
          unless  => "/usr/local/sbin/pp-postgresql-user.sh '-h ${host} -p ${port} -U ${name}' checkpwd '${host}:${port}:template1:${name}:${pgpass}'",
          require => Exec["Create postgres user $name"],
          creates => "/root/.pgpassword"
        }
      }

    }

    absent:  {
      exec { "Delete postgres user $name":
        command => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' dropuser '${name}'",
        user    => "postgres",
        onlyif  => "/usr/local/sbin/pp-postgresql-user.sh '${connection}' checkuser '${name}'",
        require => Postgresql::Cluster["main"],
      }
    }

    default: {
      fail "Invalid 'ensure' value '$ensure' for postgres::user"
    }
  }
}
