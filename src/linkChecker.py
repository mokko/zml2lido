"""
    parse a LIDO file for linkResources and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as input
    input and output are lido
    
    https://recherche.smb.museum/images/5403567_2500x2500.jpg
    lidoWrap/lido/administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource
"""

from lxml import etree
import urllib.request
from pathlib import Path

NSMAP = {"l": "http://www.lido-schema.org"}
sizes = ["_2500x2500", "_1000x600"]  # from big to small


class LinkChecker:
    def __init__(self, *, input):
        print(args.input)
        p = Path(args.input)
        ext = p.suffix
        stem = p.stem
        out_fn = str(p.with_name(stem + "-Links")) + ext
        tree = etree.parse(args.input)
        linkResource = tree.xpath(
            "//l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )
        for link in linkResource:
            if not link.text.startswith("http"):
                nl = self.guess(link=link.text)
                if nl is not None:
                    print(nl)
                    link.text = nl
        print(f"Writing back to {out_fn}")
        tree.write(out_fn, pretty_print=True)
        return out_fn

    def guess(self, *, link):
        """
        https://recherche.smb.museum/images/4305271_1000x600.jpg
        """
        p = Path(link)
        suffix = p.suffix.lower()
        mulId = p.stem
        for size in sizes:
            new_link = f"https://recherche.smb.museum/images/{mulId}{size}{suffix}"
            try:
                urllib.request.urlopen(new_link)
            except:
                pass
            # print (f"   NOT FOUND {new_link}")
            else:
                # print (f"   HIT {new_link}")
                return new_link


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)
