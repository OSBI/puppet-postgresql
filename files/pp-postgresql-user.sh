#!/bin/sh
# File managed by puppet
#
# This script is used by postgresql::user

PSQL_OPTS="$1"

case "$2" in
  checkuser)
    USRNAME="$3"
    psql ${PSQL_OPTS} -c '\du' | egrep -q "^ *${USRNAME} "
    ;;
  createuser)
    USRNAME="$3"
    USRPWD="$4"
    psql ${PSQL_OPTS} -c "CREATE USER \"${USRNAME}\" PASSWORD '${USRPWD}'"
    ;;    
  createusernopwd)
    USRNAME="$3"
    psql ${PSQL_OPTS} -c "CREATE USER \"${USRNAME}\""
    ;;
  dropuser)
    USRNAME="$3"
    psql ${PSQL_OPTS} -c "DROP USER \"${USRNAME}\""
    ;;    

  checkuserrole)
    USRNAME="$3"
    VALUE="$4"
    ROLE="$5"
    psql ${PSQL_OPTS} -tc "SELECT ${ROLE} FROM pg_roles WHERE rolname = '${USRNAME}'" | grep -q $(echo ${VALUE} | cut -c 1)
    ;;
  setuserrole)
    USRNAME="$3"
    ROLETEXT="$4"
    psql ${PSQL_OPTS} -c "ALTER USER \"${USRNAME}\" $ROLETEXT"
    ;;

  checkpwd)
    PGPASSCONTENT="$3"
    TMPFILE=$(mktemp /tmp/.pgpass.XXXXXX)
    echo "$PGPASSCONTENT" > $TMPFILE
    PGPASSFILE=$TMPFILE psql ${PSQL_OPTS} -c '\q' template1
    RESULT=$?
    rm -f $TMPFILE
    exit $RESULT
    ;;
  setpwd)
    USRNAME="$3"
    USRPWD="$4"
    psql ${PSQL_OPTS} -c "ALTER USER \"${USRNAME}\" PASSWORD '${USRPWD}' "
    ;;
  *)
    echo "$0: Gummy Bear Error"
    exit 1
esac

