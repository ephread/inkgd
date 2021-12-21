#!/usr/bin/env python3

# ./generate.py 8 && inklecate -o ipsumignious.ink.json ipsumignious.ink

import os
import argparse

from jinja2 import Environment, FileSystemLoader

# ############################################################################ #

THIS_DIR = os.path.dirname(os.path.abspath(__file__))

INK_FILE = 'ipsuminious.ink'
TEMPLATE_FILE = '%s.tmpl' % INK_FILE
JSON_FILE = '%s.json' % INK_FILE

# ############################################################################ #

parser = argparse.ArgumentParser(description='Generate an ipsuminious Ink file of the given size')
parser.add_argument('size', type=int,
                    help='The size of the story (the number of internal copies of the base story)')
parser.add_argument('--run-inklecate', action='store_true',
                    help='Compile the generated Ink file (inklecate needs to be available in $PATH)')
args = parser.parse_args()

# ############################################################################ #

env = Environment(loader=FileSystemLoader(THIS_DIR))
template = env.get_template('ipsuminious.ink.tmpl')
output = template.render(size=args.size)

with open("ipsuminious.ink", "w") as fh:
    fh.write(output)

# ############################################################################ #

if args.run_inklecate:
    os.system("inklecate -o %s %s" % (JSON_FILE, INK_FILE))
