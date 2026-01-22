# Xdot MacOS Application

## Intro

This project allows you to wrap the commandline xdot application into a MacOS
application called 'Xdot' with the following features:

- **easy opening .dot/.xdot/.gv files** with xdot by double clicking them in Finder .
  Note that extensions need to be registered to the Xdot App.
- **Drag&Drop of .dot/.xdot/.gv files** to the Xdot window which implements a droplet
  function to open them with xdot.
- **easy close all xdot windows**, which are run by individual xdot applications, by
  closing the Xdot App.

## Required

Before installing we need to install the following requirements:

1. brew install xdot
2. brew install platypus
3. brew install flock

The xdot commandline application is used to open an individual graphviz file in a
python gui window.

The platypus command is used to create an Xdot App using the scripts in this folder.

Flock is required to only keep a single instance of the cleanup script running.

## Installation

After installing the requirements above we can install the 'Xdot' App by running the
following command in the folder containing this README:

```bash
XDOT_FOLDER=$PWD
/usr/local/bin/platypus --droppable  --name 'Xdot'  \
   --interface-type 'Droplet' --interpreter '/bin/bash' \
   --bundle-identifier nl.ru.cs.xdot     --suffixes 'dot,gv,xdot' \
   --uniform-type-identifiers 'public.item'      --author 'Harco Kuppens'  \
   --bundled-file "$XDOT_FOLDER/cleanup_xdot.bash" --bundled-file "$XDOT_FOLDER/run_xdot.bash" \
      "$XDOT_FOLDER/launch_xdot.bash"  /Applications/Xdot.app/ -y
```

You're done. You can also register the 'Xdot' App as the default application for
'.dot' or '.xdot' or '.gv' files.

## Tasks per script:

- **launch_xdot.bash**: \
   Launcher for the 'Xdot' MacOS application. When the 'Xdot' App is started it
  registers this launch script to open files, and opens its own 'Xdot' App main
  window which acts as Droplet. The launcher gets files arguments either by drag&drop
  on the 'Xdot' App main window. File arguments can also be given to the launcher by
  double clicking on a .dot or .xdot file in the Finder when these extensions are
  registered to have the 'Xdot' App as default application. It then opens each file
  arguments separately using run_xdot.bash.
- **run_xdot.bash**: \
   run by launcher launch_xdot.bash to open each file argument with homebrew's xdot
  commandline application. Each xdot window gets its own window, and is run as an
  individual application, and therefore get a separate icon in the application
  switcher. When launching Python GUI application, this unfortunately happens,
  however with the cleanup_xdot.bash we found a way to easily close all windows when
  needed.
- **cleanup_xdot.bash**: \
   program launched in background by launch_xdot.bash to watch for Xdot App exiting.
  When the Xdot App exits it kills all xdot process, so all xdot's python's gui
  windows are closed when the main Xdot App exits. This allows you to easily close
  all xdot windows by closing the main app.

The scripts log into LOGFILE="/tmp/xdot_log.txt".
