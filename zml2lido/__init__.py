"""lido.py - A quick and dirty toolbox for turning zml files into LIDO"""

__version__ = "0.0.4"

import argparse
import sys
from zml2lido.lidoTool import LidoTool
from zml2lido.linkChecker import LinkChecker


def lido():
    parser = argparse.ArgumentParser(description="Little LIDO toolchain")
    parser.add_argument(
        "-c",
        "--chunks",
        help="expect the input to be multiple precisely-named chunks",
        required=False,
        action="store_true",
    )
    parser.add_argument("-i", "--input", help="zml input file", required=True)
    parser.add_argument("-j", "--job", help="pick job (e.g. smb or dd)", required=True)
    parser.add_argument(
        "-f", "--force", help="force overwrite existing lido", action="store_true"
    )
    parser.add_argument("-v", "--validate", help="validate lido", action="store_true")
    args = parser.parse_args()

    if args.force:
        args.validate = True

    print(f"JOB: {args.job}")

    m = LidoTool(
        Input=args.input, force=args.force, validation=args.validate, chunks=args.chunks
    )
    getattr(m, args.job)()


def linkChecker():
    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()
    lc = LinkChecker(input=args.input)


def saxon():
    m = LidoTool()  # just to run saxon
    parser = argparse.ArgumentParser(description="Little SAXON tool written in Python")
    parser.add_argument("-s", "--source", help="source filename", required=True)
    parser.add_argument("-o", "--output", help="output filename", required=True)
    parser.add_argument(
        "-x", "--xsl", help="(xslt) transformation filename", required=True
    )
    args = parser.parse_args()

    m.saxon(Input=args.source, xsl=args.xsl, output=args.output)


def validate():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    args = parser.parse_args()
    m = LidoTool()
    m.validate(Input=args.input)
