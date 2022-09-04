import argparse

import PyPDF4

parser = argparse.ArgumentParser('pdf merge')
parser.add_argument('-i', nargs='+')
parser.add_argument('-o', type=str)
args = parser.parse_args()

print(f'start merging...')
with open(args.o, 'wb') as ws:
    writer = PyPDF4.PdfFileWriter()
    for file in args.i:
        print(f'reading: {file}')
        with open(file, 'rb') as rs:
            pdf = PyPDF4.PdfFileReader(file)
            for page in pdf.pages:
                writer.addPage(page)
            rs.close()
    print(f'writing: {args.o}')
    writer.write(ws)
    ws.close()
print(f'done')
