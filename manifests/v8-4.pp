class postgresql::v8-4 {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        lenny,squeeze : { include postgresql::debian::v8-4 }
        default:        { fail "postgresql 8.4 not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    Ubuntu: {
      case $lsbdistcodename {
        lucid,natty :  { include postgresql::debian::v8-4 }
        default: { fail "postgresql 8.4 not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
