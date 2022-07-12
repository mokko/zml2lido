"""
    parse a LIDO file for linkResources and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as input
    input and output are lido
    
    https://recherche.smb.museum/images/5403567_2500x2500.jpg
    lidoWrap/lido/administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource
"""

import logging
import json
import urllib.request
from lxml import etree
from mpapi.sar import Sar
from pathlib import Path
from urllib import request as urlrequest
from typing import Optional, Union

NSMAP = {"l": "http://www.lido-schema.org"}
sizes = ["_2500x2500", "_1000x600"]  # from big to small

with open("sdata/credentials.py") as f:
    exec(f.read())


class LinkChecker:
    def __init__(self, *, Input):
        print(f"LinkChecker is working on {Input}")  # not exactly an error
        p = Path(Input)
        ext = "".join(p.suffixes)
        stem = str(p).split(".")[0]
        self.out_fn = stem + "-links" + ext
        # self.log(f"   writing to {self.out_fn}")
        self.tree = etree.parse(str(Input))
        self.cacheFn = stem + ".cache.json"
        if Path(self.cacheFn).exists():
            print(f"About to load {self.cacheFn}")
            with open(self.cacheFn) as jsonfile:
                self.cache = json.load(jsonfile)
        else:
            self.cache = dict()

    def log(self, msg):
        print(msg)
        logging.info(msg)

    def guess(self):
        # check first in my file cache
        linkResourceL = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )

        for link in linkResourceL:
            if link.text is not None:
                if not link.text.startswith("http"):
                    nl = self._guess(link=link.text)
                    if nl is not None:
                        link.text = nl
                    # else:
                    #    self.log(f"\tNOT FOUND {nl}")
        with open(self.cacheFn, "w", encoding="utf-8") as f:
            json.dump(self.cache, f, ensure_ascii=False, indent=4)

    def _guess(self, *, link) -> Optional[str]:
        """
        returns a link if it exists in the WWW or none if can't be reached.

        EXPECTS
        a "link" of the format "1234567.jpg"

        RETURNS
        full link to the resource in the format
        https://recherche.smb.museum/images/4305271_1000x600.jpg
        or None
        """

        p = Path(link)
        mulId = p.stem
        if p.suffix == ".pdf":
            self.log(f"   Dont even check for pdf {p}")
            return  # dont even check pdfs b/c we know that they dont work
        elif p.suffix == ".mp3":
            self.log(f"   Dont even check for mp3 {p}")
            return  # dont even check mp3 b/c we know that they dont work
        elif p.suffix == ".tif" or p.suffix == ".tiff":
            self.log(f"   Dont even check for tif/f {p}")
            return  # dont even check tif b/c we know that they dont work

        try:
            self.cache[mulId]
        except:
            pass  # mulId not yet in cache, continue below
        else:  # if try succeeds
            return self.cache[mulId]

        suffixes = [p.suffix]
        if p.suffix.lower() != p.suffix:
            suffixes.append(p.suffix.lower())
        if p.suffix.upper() != p.suffix:  # possible that i converted to upper before
            suffixes.append(p.suffix.upper())

        for size in sizes:
            for suffix in suffixes:
                new_link = f"https://recherche.smb.museum/images/{mulId}{size}{suffix}"
                req = urlrequest.Request(new_link)
                req.set_proxy(
                    "http-proxy-2.sbb.spk-berlin.de:3128", "http"
                )  # http-proxy-1.sbb.spk-berlin.de:3128
                try:
                    # urlrequest.urlopen(req)
                    urllib.request.urlopen(new_link)
                except:
                    self.cache[mulId] = None
                    self.log(f"INFO multimedia {mulId} not found")
                    return None
                else:
                    self.cache[mulId] = new_link
                    return new_link

    def rmInternalLinks(self):
        """
        Remove resourceSet whose linkResource point to internal links;
        links are internal if they dont begin with "http", e.g.
        1234678.jpg
        """
        self.log("   resourceSet: Removing sets with remaining internal links")
        linkResourceL = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )
        for link in linkResourceL:
            if link.text is not None:  # empty links seem to be new?
                if not link.text.startswith("http"):
                    resourceSet = link.getparent().getparent()
                    resourceSet.getparent().remove(resourceSet)

    def rmUnpublishedRecords(self):
        """
        Remove lido records which are not published on SMB Digital.

        Assumes that only records which have SMBFreigabe=Ja have objectPublishedID
        """
        self.log(
            "   LinkChecker: Removing lido records that are not published on recherche.smb"
        )
        recordsL = self.tree.xpath(
            "/l:lidoWrap/l:lido[not(l:objectPublishedID)]", namespaces=NSMAP
        )
        for record in recordsL:
            record.getparent().remove(record)

    def saveTree(self):
        self.log(f"Writing back to {self.out_fn}")
        self.tree.write(
            self.out_fn, pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return self.out_fn

    def fixRelatedWorks(self):
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if the link works and if not we remove that element.
        """
        self.log("   relatedWorks: Removing relatedWorks that are not online")
        relatedWorksL = self.tree.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        sar = Sar(baseURL=baseURL, user=user, pw=pw)

        for ID in relatedWorksL:
            src = ID.xpath("@l:source", namespaces=NSMAP)[
                0
            ]  # assuming that source always exists
            if src == "OBJ.ID":
                mtype = "Object"
            else:
                raise ValueError("ERROR: Unknown type")
            if ID.text is not None:
                # print (f"*****{ID.text} {mtype}")
                b = sar.checkApproval(ID=ID.text, mtype=mtype)
                print(f"relatedWorks{ID.text} {b}")
                if not (b):
                    relWorkSet = ID.getparent().getparent().getparent()
                    relWorkSet.getparent().remove(relWorkSet)
