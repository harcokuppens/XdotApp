#!/usr/bin/env python3
import sys
import subprocess
import os
import time

# --- Configuration ---
# Path to your original Bash script that contains all the xdot launching logic
BASH_SCRIPT_PATH = os.path.expanduser("~/bin/runxdot.bash")

# Path to the cleanup script that runs in the background
# CLEANUP_SCRIPT_PATH = os.path.expanduser("~/bin/xdot_cleanup.bash")
CLEANUP_SCRIPT_PATH = os.path.expanduser("~/bin/cleanup_xdot.bash")

# --- Main Logic ---


def launch_xdot_processes():
    # 1. Launch the single-instance cleanup watcher
    # We use Popen with a detached session to launch the cleaner.
    # The cleanup script handles its own single-instance check (using the lock file).
    try:
        # Use shell=True here because the cleanup script is a standard shell script
        # and we use Popen to immediately detach it.
        subprocess.Popen([CLEANUP_SCRIPT_PATH], close_fds=True, start_new_session=True)
    except Exception as e:
        # Log this error if possible, but don't fail the launch
        print(f"Error launching cleanup script: {e}", file=sys.stderr)

    # 2. Execute the original Bash script logic for file opening
    # We simply execute the bash script, passing along all arguments (the file paths)

    # Arguments passed to the Python script (sys.argv[1:]) are the file paths
    file_paths = sys.argv[1:]

    # Build the full command: bash /path/to/launchxdot.bash file1.dot file2.dot ...
    command = ["/bin/bash", BASH_SCRIPT_PATH] + file_paths

    try:
        # Execute the bash script. We DO NOT use wait() or communicate().
        # We rely on the BASH script to launch xdot with '&' and exit IMMEDIATELY.

        # We use check_call to run the script and ensure it exits with status 0
        # If the bash script exits immediately, the python script can exit immediately too.
        subprocess.check_call(
            command,
            close_fds=True,
            start_new_session=True,
        )
        # subprocess.check_call(
        #     command,
        #     close_fds=True,
        #     start_new_session=True,
        #     cwd="/Users/harcok/Documents/projects/statemachinelib/statemachinelib_repo/",
        # )
    except subprocess.CalledProcessError as e:
        print(f"Error executing launch script: {e}", file=sys.stderr)


# This is the last line of execution. The script will exit immediately after this function returns.
if __name__ == "__main__":
    launch_xdot_processes()
