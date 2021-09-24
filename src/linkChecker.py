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
from urllib import request as urlrequest
from pathlib import Path

NSMAP = {"l": "http://www.lido-schema.org"}
sizes = ["_2500x2500", "_1000x600"]  # from big to small


class LinkChecker:
    def __init__(self, *, input):
        print(f"LinkChecker is working on {input}")
        p = Path(input)
        ext = p.suffix
        stem = p.stem
        self.out_fn = str(p.with_name(stem + "-links")) + ext
        print (f"   writing to {self.out_fn}")
        self.tree = etree.parse(str(input))

    def guess (self):
        linkResource = self.tree.xpath(
            "//l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP)

        for link in linkResource:
            if not link.text.startswith("http"):
                nl = self._guess(link=link.text)
                if nl is not None:
                    print(nl)
                    link.text = nl
                else:
                    print ("   not found")
        print(f"Writing back to {self.out_fn}")
        self.tree.write(self.out_fn, pretty_print=True)
        return self.out_fn

    def _guess(self, *, link):
        """
        https://recherche.smb.museum/images/4305271_1000x600.jpg
        """
        p = Path(link)
        suffix = p.suffix.lower()
        mulId = p.stem
        for size in sizes:
            new_link = f"https://recherche.smb.museum/images/{mulId}{size}{suffix}"
            print (f"   checking {new_link}")
            req = urlrequest.Request(new_link)
            req.set_proxy("http-proxy-1.sbb.spk-berlin.de:3128", "http")
            try:
                #urlrequest.urlopen(req)
                urllib.request.urlopen(new_link)
            except:
                pass
            # print (f"   NOT FOUND {new_link}")
            else:
                print (f"   HIT {new_link}")
                return new_link


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)
