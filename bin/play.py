#!/usr/bin/env python

import os
import subprocess
import sys


"""
play: run a given ansible playbook before executing command
"""


def exit(message, status=1):
    if not message.endswith("\n"):
        message += "\n"
    sys.stderr.write(message)
    sys.exit(status)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        exit("Usage: {} PLAYBOOK COMMAND [args..]".format(sys.argv[0]))

    try:
        p = subprocess.check_call(["ansible-playbook", sys.argv[1]])
    except subprocess.CalledProcessError as e:
        exit(str(e))

    print('-'*79)

    try:
        os.execvp(sys.argv[2], sys.argv[2:])
    except OSError as e:
        exit("Cannot execute {cmd}: {e!s}".format(cmd=sys.argv[2], e=e))
