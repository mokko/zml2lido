"""
A command line tool that reads in LIDO files and executes checks. Eventually, we want to
become modular, so that we can de/activate tests. Perhaps using a config file. That 
would be a toml file.

We already have a validation tool, so we don't need to start with validation

Should we use a test framework like pytest? Probably not.
"""

import argparse
import pathlib from Path
parser = argparse.ArgumentParser(description="Quality control for LIDO files")
    parser.add_argument(
        "-i",
        "--input",
        help="specify an input file",
        required=True,
    )
    args = parser.parse_args()

