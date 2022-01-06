"""lido.py - A quick and dirty toolbox for turning zml files into LIDO"""

__version__ = "0.0.1"

import argparse
from zml2lido.lidoTool import LidoTool
from zml2lido.linkChecker import LinkChecker

def lido():
    parser = argparse.ArgumentParser(description="Little LIDO toolchin")
    parser.add_argument("-i", "--input", help="zml input file", required=True)
    parser.add_argument(
        "-j", "--job", help="pick job (localLido or smbLido)", required=True
    )
    parser.add_argument(
        "-f", "--force", help="force overwrite existing lido", action="store_true"
    )
    parser.add_argument("-v", "--validate", help="validate lido", action="store_true")
    args = parser.parse_args()

    if args.force:
        args.validate = True

    print(f"JOB: {args.job}")

    #m = LidoTool(input=args.input, force=args.force, validation=args.validate)
    #getattr(m, args.job)()

def linkChecker():
    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)
