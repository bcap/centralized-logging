#!/bin/bash

NAME="<service name>"                     # Name of the service, will be used in another vars
USER="<user name>"                        # User that will spawn the process
DAEMON="<daemon>"                         # Path to the service executable, e.g. "/usr/bin/java"
DAEMON_ARGS="<daemon args>"               # Arguments passed to the service startup, e.g. "-jar some.jar -a -b c"
MAX_STOP_WAIT=10                          # after issuing a SIGTERM, max seconds to wait before issuing a SIGKILL

PIDFILE=/var/run/${NAME}.pid              # Pid file location, defaults to /var/run/${NAME}.pid
SCRIPTNAME=/etc/init.d/$NAME              # Location of this init script
LOG_PATH=/var/log/$NAME                   # Standard output and Standard error will be outputted here

PATH=/sbin:/usr/sbin:/bin:/usr/bin

do_status() {
  if [[ -f $PIDFILE ]]; then
    PID=$(cat $PIDFILE)
    if [[ -d /proc/$PID ]]; then
      echo "=> $NAME running with pid $PID"
      return 0
    else
      echo "=> $NAME stopped (no process with pid $PID)"
      return 1
    fi
  else
    echo "=> $NAME stopped (no pid file at $PIDFILE)"
    return 1
  fi
}

do_start() {
  if do_status > /dev/null; then
    echo "=> $NAME already started with PID $(cat $PIDFILE)" &&
    return 0
  fi
  echo -e "\n\n------- starting $NAME at $(date) -------\n" >> $LOG_PATH &&
  # uses file descriptor 3 to capture the pid of process launched by su, based on
  # http://stackoverflow.com/questions/6197165/getting-a-pid-from-a-background-process-run-as-another-user
  su -l $USER -c "$DAEMON $DAEMON_ARGS 3>&- & echo \$! 1>&3" >> $LOG_PATH 2>&1 3>/tmp/.bgpid.$$ &&
  PID=$(cat /tmp/.bgpid.$$) && rm /tmp/.bgpid.$$ &&
  echo "$PID" > $PIDFILE &&
  echo "=> $NAME started with pid $PID"
}

do_stop() {
  if ! do_status > /dev/null; then
    echo "=> $NAME already stopped" &&
    return 0
  fi
  echo -e "\n\n------- stopping $NAME at $(date) -------\n" >> $LOG_PATH &&
  echo "=> stopping $NAME gracefully by issuing a SIGTERM to $PID (waiting a max of $MAX_STOP_WAIT seconds)" && kill -15 $PID && ISSUED=$(date +%s)
  while [[ -d /proc/$PID ]]; do
    if [[ $(( $(date +%s) - $ISSUED)) > $MAX_STOP_WAIT ]]; then
      echo "=> force stopping by issuing a SIGKILL to $PID as $MAX_STOP_WAIT seconds has passed" &&
      kill -9 $PID
    fi
    sleep 0.2
  done && echo "=> $NAME stopped" && rm $PIDFILE
}

# main execution

case "$1" in
  "status") do_status ;;
  "start") do_start ;;
  "stop") do_stop ;;
  "restart") do_stop; do_start ;;
  *) echo "Usage: $SCRIPTNAME {start|stop|status|restart}" >&2; exit 1 ;;
esac