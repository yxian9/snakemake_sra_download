#!/usr/bin/env python3
import json
import os
import csv
import re
from os.path import join
import argparse
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument("--meta", help="Required. the FULL path to the tab delimited meta file")
args = parser.parse_args()

assert args.meta is not None, "please provide the path to the meta file"

FILES = defaultdict(lambda: defaultdict( lambda : defaultdict(list)))
## process meta file
with open(args.meta, "r") as f:
# with open('meta.txt', "r") as f:
    reader = csv.reader(f, delimiter = "\t")
    header = next(reader) ## skip header
    for row in reader:
        if row == []: break
        sample_name = row[0].strip()
        sra_name = row[1].strip()
        ## now just assume the file name in the metafile contained in the fastq file path
        fastq_full_path = [x for x in fastq_paths if fastq_name in x]
        if fastq_full_path:
            m = re.search(r"(.*)_(L[0-9]{3})_(R[12])_[0-9]{3}.fastq.gz",fastq_name)  ## add the R1 and R2 for paired end mapping
            reads = m.group(3) 
            FILES[sample_name][sample_type][reads].extend(fastq_full_path)
            
        else:
            print("sample {sample_name} missing {sample_type} {fastq_name} fastq files".format( \
                    sample_name = sample_name, sample_type = sample_type, fastq_name = fastq_name))