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

FILES = defaultdict()

with open(args.meta, "r") as f:
# with open('meta.txt', "r") as f:
    reader = csv.reader(f, delimiter = ",")
    # header = next(reader) ## skip header
    for row in reader:
        if row == []: break
        sra_name = row[0].strip()
        sample_name = row[1].strip()+'_'+sra_name
        FILES[sample_name] = sra_name


print()
sample_num = len(FILES.keys())
print ("total {} unique samples will be downloaed".format(sample_num))
print ("------------------------------------------")
for sample in FILES.keys():
    print ("{sample} with srr ID as {n}".format(sample = sample, n = (FILES[sample])))
print ("------------------------------------------")
print("check the samples.json file for fastqs belong to each sample")
print()

js = json.dumps(FILES, indent = 4, sort_keys=True)
open('samples.json', 'w').writelines(js)