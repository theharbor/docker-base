#!/usr/bin/env python

import os
import pwd
import sys


"""
runas: run specified program under a different user/group
"""


def exit(message, status=1):
    if not message.endswith("\n"):
        message += "\n"
    sys.stderr.write(message)
    sys.exit(status)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        exit("Usage: {} USER COMMAND [args..]".format(sys.argv[0]))

    username = sys.argv[1]
    try:
        user = pwd.getpwnam(username)
    except KeyError:
        exit("User {} not found".format(username))

    os.initgroups(username, user.pw_gid)
    os.setgid(user.pw_gid)
    os.setuid(user.pw_uid)
    os.environ['USER'] = username
    os.environ['HOME'] = user.pw_dir
    os.environ['UID']  = str(user.pw_uid)

    try:
        os.execvp(sys.argv[2], sys.argv[2:])
    except OSError as e:
        exit("Cannot execute {cmd}: {e!s}".format(cmd=sys.argv[2], e=e))
