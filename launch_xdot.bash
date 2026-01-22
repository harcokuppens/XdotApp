#!/bin/bash

## launcher for Platypus Droplet App 'Xdot' App

LOGFILE="/tmp/xdot_log.txt"
LOGGING_ENABLED="true"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_PROGRAM="$SCRIPT_DIR/cleanup_xdot.bash"
RUN_PROGRAM="$SCRIPT_DIR/run_xdot.bash"

log() {
    if [[ ! "$LOGGING_ENABLED" == "true" ]]; then
        return 0
    fi
    printf "%s - " "$(date)" >>"$LOGFILE"
    for arg in "$@"; do
        printf "launch: '%s'" "$arg" >>"$LOGFILE"
    done
    printf "\n" >>"$LOGFILE"
}

export PATH="/opt/homebrew/bin/:$PATH"
log "xdot launched via launch_xdot.bash, PID: $$"
log "SCRIPT_DIR: $SCRIPT_DIR"

# ---  Launch the cleanup script (it handles the single-instance check) ---
# The '&' here ensures the main script doesn't wait for the cleanup script.
# The cleanup script handles the lock internally.
# ~/bin/xdot_cleanup.bash &
"$CLEANUP_PROGRAM" &
log "Cleanup script launched (or skipped if already running)."

# --- Main Logic ---

if [ "$#" -gt 0 ]; then
    log "Files opened with the app:" "$@"
    # Loop through all passed arguments (file paths)
    for file_path in "$@"; do
        log "Processing file: $file_path"
        "$RUN_PROGRAM" "$file_path" &
        echo "$RUN_PROGRAM" "$file_path"
        # /opt/homebrew/bin/xdot "$file_path" &
        # log "Done Processing file: $file_path"

        # ext=$(echo ${file_path##*.} | tr '[:upper:]' '[:lower:]')

        # # change to directory of the file so that in xdot we can open relative files
        # # currentdir="$(dirname ${file_path})"
        # #log "Changing directory to: $currentdir"
        # #cd "$currentdir"
        # # ;|| log "Could not change directory to $currentdir" && exit

        # # --- Launch xdot in the background, but NOT EXITING THE SCRIPT ---
        # log "File extension: $ext"
        # if [[ "$ext" != "dot" && "$ext" != "xdot" && "$ext" != "gv" ]]; then
        #     log "Skipping unsupported file type: $file_path"
        #     continue
        # elif [[ "$ext" == "xdot" ]]; then
        #     log "Opening xdot file with xdot: $file_path"
        #     /opt/homebrew/bin/xdot -n "$file_path" &
        #     #{ cd "$currentdir" && /opt/homebrew/bin/xdot -n "$file_path"; } &
        # else
        #     log "Opening dot/gv file with xdot: $file_path"
        #     #{ cd "$currentdir" && /opt/homebrew/bin/xdot "$file_path"; } &
        #     /opt/homebrew/bin/xdot "$file_path" &
        # fi
        # #cd -
    done
fi

disown -a 2>/dev/null
# Exit immediately to allow the Finder to open the next file.
log "launch_xdot.bash finished execution and is exiting immediately."
#sleep 1
exit 0
