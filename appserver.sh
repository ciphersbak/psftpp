#!/bin/bash

if [ -f /etc/init.d/functions ]; then
  . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
  . /etc/rc.d/init.d/functions
else
  exit 1
fi

unset TMPDIR

SCRIPT_NAME=$(basename $(readlink -nf $0))
LOG_FILE=/var/log/$SCRIPT_NAME.log
APPSRVDOM=E92PP126
APPSRV_ADMIN=psadm2
APPSRV_CFG_HOME=/home/psadm2/psft/pt/8.58
APPSRV_PS_HOME=/opt/oracle/psft/pt/tools
PROG="PeopleSoft Application Server Domain $APPSRVDOM"

check_application_server_installed() {
  local ret=0

  if [ -f $APPSRV_CFG_HOME/appserv/$APPSRVDOM/PSTUXCFG ]; then
    ret=1
  else
    ret=0
  fi
  return $ret
}

log_message() {
  echo "[LOG]  $(date +'%b %d %H:%M:%S') ${0##*/}: $*" >> $LOG_FILE
}

# function start Application Server domain
start_application_server () {
  ret=0

  echo -n $"Starting $PROG: "

  log_message "Starting $PROG"

  # check if application server is configured
  check_application_server_installed
  if [ $? == 1 ]; then
    # check if the domain is already started
    status=`ps -ef | grep BBL | grep $APPSRVDOM | grep appserv`
    if [ "$status" != "" ]; then
      log_message "$PROG has already been started" >/dev/null 2>&1
      success
      ret=0
    else
      su - $APPSRV_ADMIN -c "$APPSRV_PS_HOME/bin/psadmin -c start -d $APPSRVDOM" 1>>$LOG_FILE 2>&1
      ret=$?
      [ $ret -eq 0 ] && success || failure
    fi
    log_message "Started $PROG"
  else
    log_message "$PROG is not configured on this host"
    failure
    ret=1
  fi
  echo
  return $ret
}

# function stop Application Server domain
stop_application_server () {
  ret=0

  echo -n $"Stopping $PROG: "

  log_message "Stopping $PROG"

  # check if application server is configured
  check_application_server_installed
  if [ $? == 1 ]; then
    # check if the domain is already stopped
    status=`ps -ef | grep BBL | grep $APPSRVDOM | grep appserv`
    if [ "$status" == "" ]; then
      log_message "$PROG has already been stopped" >/dev/null 2>&1
      success
      ret=0
    else
      su - $APPSRV_ADMIN -c "$APPSRV_PS_HOME/bin/psadmin -c stop -d $APPSRVDOM" 1>>$LOG_FILE 2>&1
      ret=$?
      [ $ret -eq 0 ] && success || failure
    fi
    log_message "Stopped $PROG"
  else
    log_message "$PROG is not configured on this host"
    failure
    ret=1
  fi
  echo
  return $ret
}

start() {

    # start the Application Server domain
    start_application_server
    return $?
}

stop() {

    # stop the Application Server domain
    stop_application_server
    return $?
}

restart() {
    stop
    start
}

dostatus() {
  # check if application server is configured
  check_application_server_installed
  if [ $? == 1 ]; then
    # check if the App Server is running
    status=`ps -ef | grep BBL | grep $APPSRVDOM | grep appserv`
    if [ "$status" == "" ]; then
      echo "$PROG is Down"
    else
      echo "$PROG is Up"
    fi
  else
    echo "$PROG is Not Configured on this Host"
  fi
}

# Set path if path not set (if called from /etc/rc)
case $PATH in
    "") PATH=/bin:/usr/bin:/sbin:/etc
        export PATH
        ;;
esac


if [ "$(id -u)" != "0" ]; then
    echo "You must be root to run this script."
    exit 1
fi

# See how we were called
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        dostatus
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac
