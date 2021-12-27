#!/usr/bin/env python
import os
import sys


def main():
    os.system('ldc.sh ' + ' '.join(sys.argv[1:]))

if __name__ == '__main__':
    main()
