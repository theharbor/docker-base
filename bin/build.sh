#!/bin/bash

set -e
set -x
aptinstall="apt-get install --no-install-recommends --yes"

apt-get update
$aptinstall supervisor
rm -rf /var/lib/apt/lists/*

# Replace start stop and restart commands with wrapper to supervisorctl
rm /sbin/{start,stop,restart}
for file in start stop restart
do
    ln -s /usr/local/sbin/servicewrapper /usr/local/sbin/$file
done
