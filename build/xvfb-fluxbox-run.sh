#!/bin/sh
set -e

xvfb_start() {
    # Set defaults if the user did not specify envs.
    export DISPLAY=${XVFB_DISPLAY:-:1}
    local screen=${XVFB_SCREEN:-0}
    local resolution=${XVFB_RESOLUTION:-1920x1080x24}
    local timeout=${XVFB_TIMEOUT:-5}

    # Start and wait for either Xvfb to be fully up or we hit the timeout.
    Xvfb ${DISPLAY} -screen ${screen} ${resolution} &
    local loopCount=0
    until xdpyinfo -display ${DISPLAY} > /dev/null 2>&1
    do
        loopCount=$((loopCount+1))
        sleep 1
        if [ ${loopCount} -gt ${timeout} ]
        then
            echo "[ERROR] xvfb failed to start."
            exit 1
        fi
    done
}

xvfb_stop() {
    killall Xvfb
}

fluxbox_start() {
    local timeout=${XVFB_TIMEOUT:-50}

    # Start and wait for either fluxbox to be fully up or we hit the timeout.
    fluxbox &
    local loopCount=0
    until wmctrl -m > /dev/null 2>&1
    do
        loopCount=$((loopCount+1))
        sleep 1
        if [ ${loopCount} -gt ${timeout} ]
        then
            echo "[ERROR] fluxbox failed to start."
            exit 1
        fi
    done
}

fluxbox_stop() {
    killall fluxbox
}

xvfb_start
fluxbox_start

# Start the command and save its exit status.
set +e
eval "$@"
RETVAL=$?
set -e

#fluxbox_stop
#xvfb_stop

# Return the executed command's exit status.
exit $RETVAL
