"""lido.py - A quick and dirty toolbox for turning zml files into LIDO

Version 0.0.7 introduces relWorksCache
Version 0.0.8 switches to saxonche
"""

__version__ = "0.0.8"


import argparse
from zml2lido.lidoTool import LidoTool
from zml2lido.linkChecker import LinkChecker
from zml2lido.vocmap import Vocmap

NSMAP = {"l": "http://www.lido-schema.org"}


def lfilter():
    parser = argparse.ArgumentParser(description="Little LIDO toolchain")
    parser.add_argument(
        "-c",
        "--chunks",
        help="expect the input to be multiple precisely-named chunks",
        required=False,
        action="store_true",
    )
    parser.add_argument(
        "-f", "--force", help="force overwrite existing lido", action="store_true"
    )
    parser.add_argument("-i", "--input", help="zml input file", required=True)
    parser.add_argument(
        "-s",
        "--split",
        help="split the resulting file overwriting existing split files",
        action="store_true",
    )
    parser.add_argument(
        "-t",
        "--Type",
        help="select the element that needs to go [Inhalt, Literatur]",
        required=True,
    )
    parser.add_argument("-v", "--validate", help="validate resulting lido file")

    args = parser.parse_args()

    if args.force:
        args.validate = True

    if args.chunks:
        raise TypeError("ERROR: Filter in chunking mode not implemented yet!")

    m = LidoTool(
        Input=args.input, force=args.force, validation=args.validate, chunks=args.chunks
    )

    m.lfilter(Type=args.Type, split=args.split)


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

    lt = LidoTool(
        src=args.input, force=args.force, validation=args.validate, chunks=args.chunks
    )
    lt.execute(args.job)


def linkChecker():
    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()
    lc = LinkChecker(input=args.input)


def saxon():
    parser = argparse.ArgumentParser(description="Little SAXON tool written in Python")
    parser.add_argument("-s", "--source", help="source filename", required=True)
    parser.add_argument("-o", "--output", help="output filename", required=True)
    parser.add_argument(
        "-x", "--xsl", help="(xslt) transformation filename", required=True
    )
    args = parser.parse_args()
    m = LidoTool(src=args.source)  
    m.saxon(xsl=args.xsl, output=args.output)


def validate():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    args = parser.parse_args()
    # can we have an option to validate consecutively numbered files?
    # query570068-chunk283.lido.xml
    # query570068-chunk284.lido.xml
    m = LidoTool(src=args.input)
    m.validate() # raises if does not validate


def vocmap():
    """
    Work in progress. Unfinished.
    """
    parser = argparse.ArgumentParser(description="vocmap convertor")
    parser.add_argument(
        "-i",
        "--Input",
        help="input file",
        required=True,
    )

    parser.add_argument(
        "-o",
        "--output",
        help="output file",
        required=True,
    )

    args = parser.parse_args()
    vm = Vocmap(Input=args.Input, output=args.output)
