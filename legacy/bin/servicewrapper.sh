#!/bin/sh

# This shell script wraps the start, stop and restart commands
# from ubuntu to call supervisor.

ACTION=$(basename $0)
exec supervisorctl $ACTION "$@"
