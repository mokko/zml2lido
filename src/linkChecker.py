"""
    parse a LIDO file for linkResources and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as input
    input and output are lido
    
    https://recherche.smb.museum/images/5403567_2500x2500.jpg
    lidoWrap/lido/administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource
"""

import logging
import urllib.request
from lxml import etree
from pathlib import Path
from urllib import request as urlrequest

NSMAP = {"l": "http://www.lido-schema.org"}
sizes = ["_2500x2500", "_1000x600"]  # from big to small


class LinkChecker:
    def __init__(self, *, input):
        print(f"LinkChecker is working on {input}")
        p = Path(input)
        ext = "".join(p.suffixes)
        stem = str(p).split(".")[0]
        self.out_fn = stem + "-links" + ext
        self.log(f"   writing to {self.out_fn}")
        self.log(f"   writing to {self.out_fn}")
        self.tree = etree.parse(str(input))

    def log(self, msg):
        print(msg)
        logging.info(msg)

    def guess(self):
        linkResource = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )

        for link in linkResource:
            if not link.text.startswith("http"):
                nl = self._guess(link=link.text)
                if nl is not None:
                    link.text = nl
                else:
                    self.log("\tNOT FOUND")

    def _guess(self, *, link):
        """
        https://recherche.smb.museum/images/4305271_1000x600.jpg
        """
        p = Path(link)
        mulId = p.stem
        suffixes = [p.suffix]
        if p.suffix == ".pdf":
            self.log(f"   Dont even check for pdf {p}")
            return  # dont even check pdfs b/c we know that they dont work
        elif p.suffix == ".mp3":
            self.log(f"   Dont even check for mp3 {p}")
            return  # dont even check mp3 b/c we know that they dont work
        elif p.suffix == ".tif":
            self.log(f"   Dont even check for tif {p}")
            return  # dont even check tif b/c we know that they dont work

        if p.suffix.lower() != p.suffix:
            suffixes.append(p.suffix.lower())
        for size in sizes:
            for suffix in suffixes:
                new_link = f"https://recherche.smb.museum/images/{mulId}{size}{suffix}"
                self.log(f"   checking {new_link}")
                req = urlrequest.Request(new_link)
                req.set_proxy("http-proxy-1.sbb.spk-berlin.de:3128", "http")
                try:
                    # urlrequest.urlopen(req)
                    urllib.request.urlopen(new_link)
                except:
                    pass
                else:
                    self.log("\tHIT")
                    return new_link

    def rmInternalLinks(self):
        """
        Remove resourceSet whose linkResouce point to internal links;
        links are internal if they dont begin with "http", e.g.
        1234678.jpg
        """
        self.log("   resourceSet: Removing sets with remaining internal links")
        linkResource = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )
        for link in linkResource:
            if not link.text.startswith("http"):
                resourceSet = link.getparent().getparent()
                resourceSet.getparent().remove(resourceSet)

    def rmUnpublishedRecords(self):
        """
        Remove lido records which are not published on SMB Digital.

        Assumes that only records which have SMBFreigabe=Ja have objectPublishedID
        """
        self.log("   LinkChecker: Removing records sets that are not published on SMB")
        records = self.tree.xpath(
            "/l:lidoWrap/l:lido[not(l:objectPublishedID)]", namespaces=NSMAP
        )
        for record in records:
            record.getparent().remove(record)

    def saveTree(self):
        self.log(f"Writing back to {self.out_fn}")
        self.tree.write(
            self.out_fn, pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return self.out_fn


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="LIDO URLmaker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)
