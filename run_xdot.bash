#!/bin/bash

XDOT_PROGAM="/opt/homebrew/bin/xdot"
#export PATH="/opt/homebrew/bin/:$PATH"

#log "xdot launched via runxdot.bash, PID: $$"

LOGFILE="/tmp/xdot_log.txt"
LOGGING_ENABLED="true"

log() {
    if [[ ! "$LOGGING_ENABLED" == "true" ]]; then
        return 0
    fi
    printf "%s - " "$(date)" >>"$LOGFILE"
    for arg in "$@"; do
        printf "run: '%s'" "$arg" >>"$LOGFILE"
    done
    printf "\n" >>"$LOGFILE"
}

# --- Main Logic ---

file_path="$1"

# NOTE: Using 'cd' inside a Platypus Droplet is generally unnecessary and can lead to
# unexpected behavior, as the script's execution context is already set by Platypus.
# It's better to use absolute paths or rely on PATH.

ext=$(echo ${file_path##*.} | tr '[:upper:]' '[:lower:]')

#IMPORTANT: change directory causes asking for permissions on macOS
# change to directory of the file so that in xdot we can open relative files

# # --- Launch xdot in the background, but NOT EXITING THE SCRIPT ---

# if [[ "$ext" != "dot" && "$ext" != "xdot" && "$ext" != "gv" ]]; then
#     log "Skipping unsupported file type: $file_path"
# elif [[ "$ext" == "xdot" ]]; then
#     #log "Opening xdot file with xdot: $file_path"
#     "$XDOT_PROGAM" -n "$file_path" </dev/null >/dev/null 2>&1 &
# else
#     #log "Opening dot/gv file with xdot: $file_path"
#     #log ""$XDOT_PROGAM" '$file_path'"
#     "$XDOT_PROGAM" "$file_path" </dev/null >/dev/null 2>&1 &
# fi

if [[ "$ext" != "dot" && "$ext" != "xdot" && "$ext" != "gv" ]]; then
    log "Skipping unsupported file type: $file_path"
elif [[ "$ext" == "xdot" ]]; then
    log "Opening xdot file with xdot: $file_path"
    ("$XDOT_PROGAM" -n "$file_path" </dev/null >/dev/null 2>&1 &)
else
    log "Opening dot/gv file with xdot: $file_path"
    #log ""$XDOT_PROGAM" '$file_path'"
    ("$XDOT_PROGAM" "$file_path" </dev/null >/dev/null 2>&1 &)
fi

disown -a

exit 0
