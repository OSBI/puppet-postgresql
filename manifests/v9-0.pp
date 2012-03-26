class postgresql::v9-0 {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        squeeze : { include postgresql::debian::v9-0 }
        default:  { fail "postgresql 9.0 not available for ${operatingsystem}/${lsbdistcodename}"}
      }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
