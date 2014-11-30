#!/usr/bin/env python

import sys
import os
import pwd
import pexpect


def exit(message, status=1):
    if not message.endswith("\n"):
        message += "\n"
    sys.stderr.write(message)
    sys.exit(status)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        exit("Usage: {} PLAYBOOK USERNAME COMMAND [args..]".format(sys.argv[0]))

    username = sys.argv[2]
    try:
        user = pwd.getpwnam(username)
    except KeyError:
        exit("User {} not found".format(username))

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

    os.initgroups(username, user.pw_gid)
    os.setgid(user.pw_gid)
    os.setuid(user.pw_uid)
    os.environ['USER'] = username
    os.environ['HOME'] = user.pw_dir
    os.environ['UID']  = str(user.pw_uid)

    try:
        os.execvp(sys.argv[3], sys.argv[3:])
    except OSError as e:
        exit("Cannot execute {cmd}: {e!s}".format(cmd=sys.argv[3], e=e))
