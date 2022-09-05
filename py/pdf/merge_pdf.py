import argparse
import os
import re

import PyPDF4
from PyPDF4.utils import PyPdfError

Reset = '\033[0m'
Red = '\033[1;31m'
Green = '\033[1;32m'
Yellow = '\033[1;33m'
Blue = '\033[1;34m'
Grey = '\033[1;37m'

parser = argparse.ArgumentParser('pdf merge')
parser.add_argument('-i', nargs='+')
parser.add_argument('-o', type=str)
args = parser.parse_args()

print(f'{Grey}start merging...{Reset}')
if os.path.exists(args.o):
    if re.match(r'[n|N]', input(f'{args.o} already exist may be overwrite, process?[y/n]')):
        print(f'{Green}exit{Reset}')
        exit(0)

writer = PyPDF4.PdfFileWriter()

for file in args.i:
    print(f'{Grey}reading: {file}{Reset}')
    with open(file, 'rb') as rs:
        try:
            pdf = PyPDF4.PdfFileReader(file)
            for page in pdf.pages:
                writer.addPage(page)
        except PyPdfError as err:
            print(f'{Red}READING {file} ERROR: {err}!{Reset}')
            exit(-1)
        finally:
            rs.close()

print(f'{Grey}writing: {args.o}{Reset}')
with open(args.o, 'wb') as ws:
    try:
        writer.write(ws)
    except PyPdfError as err:
        if os.path.exists(args.o):
            print(f'remove err file')
            os.remove(args.o)
        print(f'{Red}WRITING {args.o} ERROR: {err}!{Reset}')
        exit(-2)
    finally:
        ws.close()

print(f'{Green}Done{Reset}')
