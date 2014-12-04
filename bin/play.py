#!/usr/bin/env python

import os
import sys
import pexpect


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

    p = pexpect.spawn("ansible-playbook", [sys.argv[1]])
    while True:
        line = p.readline()
        if line == "":
            break
        sys.stdout.write(line)
        sys.stdout.flush()
    p.close()

    print('-'*79)
    if p.exitstatus != 0:
        exit("ansible-playbook exited with non-zero exit status!")

    try:
        os.execvp(sys.argv[2], sys.argv[2:])
    except OSError as e:
        exit("Cannot execute {cmd}: {e!s}".format(cmd=sys.argv[2], e=e))
