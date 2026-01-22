#!/bin/bash

# --- xdot_cleanup.bash ---

# Configuration
APP_BUNDLE_ID="nl.ru.cs.xdot"
XDOT_PROCESS_NAME="xdot"
APP_EXECUTABLE_NAME="Xdot"
# Use a temporary directory for the lock file
LOCK_FILE="/tmp/$APP_BUNDLE_ID.cleanup.lock"

LOGFILE="/tmp/Xdot.log"
LOGGING_ENABLED="true"

export PATH="/opt/homebrew/bin/:$PATH"

log() {
    if [[ ! "$LOGGING_ENABLED" == "true" ]]; then
        return 0
    fi
    printf "%s - " "$(date)" >>"$LOGFILE"
    for arg in "$@"; do
        printf "cleanup: '%s'" "$arg" >>"$LOGFILE"
    done
    printf "\n" >>"$LOGFILE"
}

# --- Single-Instance Lock Check ---

# Attempt to create the lock file and acquire an exclusive lock (>>| is non-standard but robust)
# We use 'set -C' (noclobber) to prevent overwriting the file if it exists, but use 'flock' for reliability.

# Open the lock file descriptor
LOCK_FD=200
exec 200>$LOCK_FILE

# Attempt to acquire a non-blocking exclusive lock (9: LOCK_NB | 2: LOCK_EX)
if ! flock -n $LOCK_FD; then
    # Lock failed (another instance is running)
    log "Cleanup script already running. Exiting."
    exit 0
else
    log "Cleanup script lock acquired."
fi

# Lock acquired successfully. Register cleanup on exit.
cleanup_lock() {
    # Remove the lock file when this instance exits (on user quitting the app)
    flock -u $LOCK_FD
    rm -f $LOCK_FILE
}
trap cleanup_lock EXIT

log "Cleanup script started and lock acquired. PID: $$"

# --- Main Logic: Wait for the main app to quit ---

#sleep 5 # Initial delay to allow the app to start properly

# Wait until the main Xdot App process is gone (meaning the user quit it)
# We use 'pgrep -f' to search for the full command line to be sure to match the app wrapper
# which pgrep >>"$LOGFILE"
# echo "$APP_EXECUTABLE_NAME" >>"$LOGFILE"
# echo "$USER" >>"$LOGFILE"
# pgrep -fil "$APP_EXECUTABLE_NAME" >>"$LOGFILE"
while command pgrep -fil "${APP_EXECUTABLE_NAME}.app" >>/dev/null; do
    sleep 2 # Check every 2 seconds
done

log "$APP_EXECUTABLE_NAME has quit. Killing all remaining $XDOT_PROCESS_NAME processes."

# Use killall to terminate all instances of the xdot executable.
#killall -TERM "$XDOT_PROCESS_NAME" 2>/dev/null

pkill -fil /opt/homebrew/bin/xdot 2>/dev/null

exit 0
# The trap EXIT will now run and remove the lock file.
