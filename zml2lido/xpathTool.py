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
    hit_count = 0
    for file_count, xml_fn in enumerate(Path(".").glob(Input), start=1):
        print(f"parsing {xml_fn}")
        tree = etree.parse(xml_fn)
        resL = tree.xpath(xpath, namespaces=NSMAP)
        hit_count += len(resL)
        _output(file=file, results=resL)
    print(f"Total {hit_count} hits in {file_count} files.")


#
# somewhat restricted
#


def _output(*, file: bool, results: list) -> None:
    out_fn = Path("xpath.xml")
    for idx, resultN in enumerate(results):
        if file:  # if output to file then stringify
            xml = etree.tostring(resultN, pretty_print=True, encoding="unicode")
            if idx == 0:
                with open(out_fn, "w") as f:
                    f.write(xml)
            else:
                with open(out_fn, "a") as f:
                    f.write(xml)
        else:
            print(resultN)  # not stringified
