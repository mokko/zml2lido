"""lido.py - A quick and dirty toolbox for turning zml files into LIDO"""

__version__ = "0.0.1"

import argparse
import sys
from zml2lido.lidoTool import LidoTool
from zml2lido.linkChecker import LinkChecker
import zml2lido.validate

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

    m = LidoTool(input=args.input, force=args.force, validation=args.validate)
    getattr(m, args.job)()


def linkChecker():
    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)


def saxon():
    m = LidoTool() # just to run saxon
    m._saxon(input=sys.argv[1], xsl=sys.argv[2], output=sys.argv[3])
    # todo debug/test
    
def validate():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    parser.add_argument("-s", "--schema", required=True)
    args = parser.parse_args()
    Validate(Input=args.input, schema=args.schema)
