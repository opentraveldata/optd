#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import with_statement

import sys

# Fields

def main(source, target, sep, fields, old, new):

    with open(source) as s:

        with open(target, 'w') as t:

            for row in s:

                if not row or row.startswith('#'):
                    continue

                row = row.strip().split(sep)

                for field in fields:
                    if row[field] == old:
                        row[field] = new

                t.write(sep.join(row) + '\n')


if __name__ == '__main__':

    if len(sys.argv) < 6:
        print 'python %s SOURCE SEPARATOR FIELDS OLD NEW' % sys.argv[0]
        print 
        print 'Example: python %s best_coordinates_known_so_far.csv "^" 2,3 0 ""' % sys.argv[0]
        exit()

    fields = [int(f) for f in sys.argv[3].split(',')]

    main(sys.argv[1], 
         sys.argv[1] + '.new',
         sys.argv[2], 
         fields, 
         sys.argv[4], 
         sys.argv[5])
