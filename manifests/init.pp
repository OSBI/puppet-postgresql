class postgresql {
  case $operatingsystem {
    Debian: { 
      case $lsbdistcodename {
        lenny :  { include postgresql::debian::v8-3 }
        squeeze: { include postgresql::debian::v8-4 }
        default: { fail "postgresql not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    } 
    Ubuntu: {
      case $lsbdistcodename {
        lucid :  { include postgresql::debian::v8-4 }
        precise: { include postgresql::ubuntu::v9-1 }
        default: { fail "postgresql not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
