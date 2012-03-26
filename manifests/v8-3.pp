class postgresql::v8-3 {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        lenny :  { include postgresql::debian::v8-3 }
        default: { fail "postgresql 8.3 not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
