#!/usr/bin/env python3
import glob
import os
import subprocess

macro_file = "macros.m"

# find all .in files
input_files = glob.glob("*.in")

for infile in input_files:
    base = infile.rsplit(".", 1)[0]          # "something" from "something.in"
    outdir = base                            # subfolder
    outfile = os.path.join(outdir, "ipf.conf")  # "something/ipf.conf"

    # create the folder if it doesn't exist
    os.makedirs(outdir, exist_ok=True)

    print(f"Processing {infile} -> {outfile}")

    # run the macro processor and write output
    with open(outfile, "w") as f:
        subprocess.run(["python3", "macroproc.py", macro_file, infile], stdout=f)
