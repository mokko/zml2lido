from lxml import etree
from pathlib import Path

# NSMAP is already present in linkChecker TODO
NSMAP = {"l": "http://www.lido-schema.org"}


def xpathTool(
    *, Input: str, xpath: str, file: bool = False, globbing: bool = False
) -> None:
    print(f"{Input=}")
    print(f"{xpath=}")
    print(f"{file=} (stringify implicit with file option)")
    out_fn = Path("xpath.xml")
    if file:
        if out_fn.exists():
            out_fn.unlink()
    for xml_fn in Path(".").glob(Input):
        print(f"parsing {xml_fn}")
        tree = etree.parse(xml_fn)
        resL = tree.xpath(xpath, namespaces=NSMAP)
        _output(file=file, results=resL, out_fn=out_fn)


#
# somewhat restricted
#


def _output(*, file: bool, results: list, out_fn: Path) -> None:
    # delete file first then append
    for resultN in results:
        if file:  # stringify automatically
            xml = etree.tostring(resultN, pretty_print=True, encoding="unicode")
            with open(out_fn, "a") as f:
                f.write(xml)
        else:
            print(resultN)  # not stringified
