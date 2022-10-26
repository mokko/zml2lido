"""

Tool that rewrites vocmap data from Excel to xml and vice versa

vocmap -i in.xslx -o out.xml
vocmap -i in.xml -o out.xslx

"""

class Vocmap:
    from pathlib import Path
    from lxml import etree

    def __init__(self, *, Input, output):
        Input = Path(Input)
        output = Path(output)
        if Input.suffix == ".xml":
            xml2xlsx(Input=Input, output=output)
        elif Input.suffix == ".xlsx":
            xlsx2xml(Input=Input, output=output)
        else:
            raise SyntaxError("ERROR: Unrecognized input suffix!")

    def xlsx2xml(self, *, Input, output):
        pass

    def xml2xlsx(self, *, Input, output):
        doc = etree.parse(str(Input))
        vocL = doc.xpath("/vocmap/voc")
        for voc in vocL:
            name = voc.get("name")
            print(f"voc {name}")
