#!/usr/bin/env python3

import os
import argparse

from jinja2 import Environment, FileSystemLoader

# ############################################################################ #

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_FILE = 'ipsuminious.ink.tmpl'

# ############################################################################ #

parser = argparse.ArgumentParser(description='Generate an ipsuminious Ink files')
parser.add_argument('-s', '--size', type=int,
                    help='When set, generates only one story with the given size'\
                         '(the number of internal copies of the base story)')
parser.add_argument('-r', '--run-inklecate', action='store_true',
                    help='Compile the generated Ink file (inklecate needs to be available in $PATH)')
args = parser.parse_args()

# ############################################################################ #

if hasattr(parser, "size"):
    sizes = [parser.size]
else:
    sizes = [1, 6, 12]

for size in sizes:
    env = Environment(loader=FileSystemLoader(THIS_DIR))
    template = env.get_template(TEMPLATE_FILE)
    output = template.render(size=size)

    if hasattr(parser, "size"):
        name = "ipsuminious.ink"
    else:
        name = "ipsuminious.%d.ink" % size

    with open(name, "w") as fh:
        fh.write(output)

    if args.run_inklecate:
        json_file = '%s.json' % name
        os.system("inklecate -o %s %s" % (json_file, name))

# ############################################################################ #
