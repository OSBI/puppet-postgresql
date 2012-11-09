class postgresql {
  case $::operatingsystem {
    /^(Debian|Ubuntu)$/ : { include postgresql::debian }
    /^(RedHat|CentOS)$/ : { include postgresql::redhat }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
