#!/bin/bash
# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

set -e

# This script queries XWindows parameters and writes them to an environment file
# for sharing with services like k3s and docker, who otherwise do not have ways
# to easily query these values.

mkdir -p "${HOME}/soafee"
[ -f "${HOME}/soafee/.soafee-xenv" ] || touch "${HOME}/soafee/.soafee-xenv"

# if dcv is available, get the display index
if which dcv >/dev/null; then
    display=$(dcv list-sessions --json \
        | jq -r --arg user "${USER}" 'first(.[] | select(.name == $user) | .["x11-display"]) // ""')

    if [ $? -ne 0 ]; then
        echo "'dcv list-sessions' exited with an error code. Not updating SOAFEE DCV display index for user ${USER}."
    elif [ -z "${display}" ]; then
        echo "failed to find display index from 'dcv list-sessions'. Not updating SOAFEE DCV display index for user ${USER}."
    else
        echo "dcv session '${USER}' found with display index ${display}."
    fi
else
    echo "DCV not found, not updating SOAFEE DCV display index for user ${USER}."
fi

set -x
if [ -n "${display}" ]; then
    # update or append DISPLAY=
    if grep -q '^DISPLAY=' "${HOME}/soafee/.soafee-xenv"; then
        sed -i 's/^DISPLAY=.*/DISPLAY='"${display}"'/' "${HOME}/soafee/.soafee-xenv"
    else
        echo "DISPLAY=${display}" >> "${HOME}/soafee/.soafee-xenv"
    fi

    # update or append SOAFEE_DCV_SESSION_DISPLAY=
    if grep -q '^SOAFEE_DCV_SESSION_DISPLAY=' "${HOME}/soafee/.soafee-xenv"; then
        sed -i 's/^SOAFEE_DCV_SESSION_DISPLAY=.*/SOAFEE_DCV_SESSION_DISPLAY='"${display}"'/' "${HOME}/soafee/.soafee-xenv"
    else
        echo "SOAFEE_DCV_SESSION_DISPLAY=${display}" >> "${HOME}/soafee/.soafee-xenv"
    fi
fi

chmod +x "${HOME}/soafee/.soafee-xenv"
