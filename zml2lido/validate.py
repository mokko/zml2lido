"""
Using lxml to validate xml files on the command line.
USAGE
    validate.py bla.xml

1. Locate schemalocation. It's an attribute. It could be in root. There could be multiple, I guess
2. Parse schemaLocation
3. Using lxml load xml and xsd to memory
4. validate
"""

from pathlib import Path
from lxml import etree

# let's put local copies on directory to speed up the process
lib = Path(__file__).joinpath("../../xsd").resolve()

conf = {}
conf["mpx"] = lib.joinpath("mpx20.xsd")
conf["lido"] = lib.joinpath("lido-v1.0.xsd")
conf["zml"] = lib.joinpath("module_1_6.xsd")


def validate(*, input, schema):
    if schema in conf:
        # print(f"schema: {schema}")
        print(f"***Looking for xsd at {conf[schema]} to validate {input}")
        schema_doc = etree.parse(str(conf[schema]))
    else:
        raise Exception("Unknown schema")
    schema = etree.XMLSchema(schema_doc)
    # print ('*About to load input document...')
    doc = etree.parse(input)
    schema.assert_(doc)
    print("***VALIDATES OK")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    parser.add_argument("-s", "--schema", required=True)
    args = parser.parse_args()
    validate(input=args.input, schema=args.schema)
