#!/usr/bin/env python

import json
import os
import sys

def inventory():
    groups = {
        'all': ["localhost"],
        'local': ["localhost"]
    }
    groups['_meta'] = {
        'hostvars': {
            'localhost': {"ENV": dict(os.environ)}
        }
    }
    groups['_meta']['hostvars']['localhost']['ansible_connection'] = "local"

    return groups


if __name__ == '__main__':
    if len(sys.argv) == 2 and (sys.argv[1] == '--list'):
        print(json.dumps(inventory()))
    else:
        sys.stderr.write("Usage: {} --list\n".format(sys.argv[0]))
        sys.exit(1)
