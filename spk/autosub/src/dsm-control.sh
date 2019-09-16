#!/bin/sh

# Package
PACKAGE="autosub"
DNAME="AutoSub"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PYTHON_DIR="/usr/local/python"
GIT_DIR="/usr/local/git"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/env/bin:${PYTHON_DIR}/bin:${GIT_DIR}/bin:${PATH}"
PYTHON="${INSTALL_DIR}/env/bin/python"
BUILDNUMBER="$(/bin/get_key_value /etc.defaults/VERSION buildnumber)"
AUTOSUB="${INSTALL_DIR}/AutoSub.py"
PID_FILE="${INSTALL_DIR}/AutoSub.pid"
LOG_FILE="${INSTALL_DIR}/AutoSubService.log"

SC_USER="sc-autosub"
LEGACY_USER="autosub"
USER="$([ "${BUILDNUMBER}" -ge "7321" ] && echo -n ${SC_USER} || echo -n ${LEGACY_USER})"

start_daemon ()
{
    # Launch the application in the background
	 su - ${USER} -s /bin/sh -c "${PYTHON} ${AUTOSUB} -d -l"
	
}

stop_daemon ()
{
    # Kill the application
    kill `find /proc -maxdepth 1 -user ${USER} -exec /usr/bin/basename {} \;`
}

daemon_status ()
{
    if [ `find /proc -maxdepth 1 -user ${USER} -exec /usr/bin/basename {} \; | wc -l` -gt 0 ]
    then
        return 0
    else
        return 1
    fi
}

run_in_console ()
{
    # Launch the application in the foreground
    su - ${USER} -s /bin/sh -c "${PYTHON} ${AUTOSUB} -l"
}

case $1 in
    start)
            echo Starting ${DNAME} ...
            start_daemon
            exit $?
        ;;
    stop)
            echo Stopping ${DNAME} ...
			stop_daemon
            exit 0
        ;;
   status)
	 if daemon_status
        then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    console)
        run_in_console
        exit $?
        ;;
    log)
        echo ${LOG_FILE}
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
