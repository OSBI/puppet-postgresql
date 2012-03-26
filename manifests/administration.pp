/*

==Class: postgresql::administration

This class will create a "postgresql-admin" group and add a couple of rules
to /etc/sudoers allowing members of this group to administer postgresql databases.

Requires:
 - definition sudo::directive from module camptocamp/puppet-sudo

*/
class postgresql::administration {

  group { "postgresql-admin":
    ensure => present,
  }

  sudo::directive { "postgresql-administration":
    ensure  => present,
    content => template("postgresql/sudoers.postgresql.erb"),
    require => Group["postgresql-admin"],
  }

}
