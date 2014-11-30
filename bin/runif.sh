#!/bin/bash

if [[ $1 == "-h" || $1 == "--help" || $# -lt 2 ]]
then
    echo "Usage: runif ENV_KEY PROGRAM [args..]"
    echo
    echo "Runs the specified program only if ENV_KEY is truthy"
    exit 2
fi

if [[ ${!1} == "yes" || ${!1} == 1 || ${!1} == "1" || ${!1} == "true" || ${!1} == "True" ]]
then
    shift
    exec "$@"
else
    echo "Not running $2 because ${1}=\"${!1}\""
    # We must wait more than "startsecs" seconds (as defined in the supervisor
    # config for this application) otherwise supervisor will consider the exit
    # unexpected.
    sleep ${RUNIF_WAIT_SECS:-1}
    exit 0
fi
