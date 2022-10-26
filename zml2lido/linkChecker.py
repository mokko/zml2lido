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

cred_fn = "sdata/credentials.py"
if Path(cred_fn).exists():  # some things like saxon should run even
    with open(cred_fn) as f:  # credentials are not where expected
        exec(f.read())


class LinkChecker:
    def __init__(self, *, Input):
        self.log(f"LinkChecker is working on {Input} NEW RUN")  # not exactly an error
        # determine out_fn
        p = Path(Input)
        ext = "".join(p.suffixes)
        stem = str(p).split(".")[0]
        self.out_fn = stem + "-links" + ext

        self.tree = etree.parse(str(Input))

        # cache for guessing external linkResources
        self.cacheFn = stem + ".cache.json"
        if Path(self.cacheFn).exists():
            print(f"About to load {self.cacheFn}")
            with open(self.cacheFn) as jsonfile:
                self.cache = json.load(jsonfile)
        else:
            self.cache = dict()

    def fixRelatedWorks(self):
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if they are SMB-approved (using MpApi) and, if not, we remove them.
        """

        self.log("fixRelatedWorks: Removing relatedWorks that are not online")
        relatedWorksL = self.tree.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        sar = Sar(baseURL=baseURL, user=user, pw=pw)

        for ID in relatedWorksL:
            # don't log
            # self.log(f"fixRelatedWorks checking {ID.text}")

            # assuming that source always exists
            src = ID.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                mtype = "Object"
            elif src == "LIT.ID":
                mtype = "Literature"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")
            if ID.text is not None:
                # print (f"*****{ID.text} {mtype}")
                if mtype == "Literature":
                    print("WARN: No check for mtype 'Literature'")
                else:
                    if mtype + ID.text in self.cache:
                        # print(f"--> from CACHE")
                        b = self.cache[mtype + ID.text]
                    else:
                        # print("--> new check")
                        b = sar.checkApproval(ID=ID.text, mtype=mtype)
                        self.cache[mtype + ID.text] = b
                    print(f"relatedWorks {ID.text} {b}")
                    if not b:
                        self.log(f"\tremoving unpublic relatedWorks")
                        relWorkSet = ID.getparent().getparent().getparent()
                        relWorkSet.getparent().remove(relWorkSet)
            self._save_cache()

    def guess(self):
        """
        Look at a every linkResource in the current lido tree. For each link
        that doesn't start with http try to guess the link. Also write a
        cache file.
        """
        # check first in my file cache
        linkResourceL = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )

        self.log(
            "guess: replacing internal linkResouces with public URLs or deleting resourceSet"
        )
        self.log(
            f" note: there are {len(linkResourceL)} links to check; {len(self.cache)} are currently in the cache"
        )
        for link in linkResourceL:
            if link.text is not None:
                if not link.text.startswith("http"):
                    nl = self._guess(link=link.text)
                    if nl is None:  # delete internal linkResources
                        self.log(f" removing rSets for linkResource '{link.text}'")
                        resourceSet = link.getparent().getparent()
                        resourceSet.getparent().remove(resourceSet)
                    else:
                        link.text = nl
                    # else:
                    #    self.log(f"\tNOT FOUND {nl}")
            # for debugging we might want to save the cache after every guess
            self._save_cache()

    def new_check(self):
        """
        For all linkResources, check if url responds ok
        """
        linkResourceL = self.tree.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )

        print("NEW CHECKER")
        for link in linkResourceL:
            if link.text is not None:
                print(link.text)
                # req = urlrequest.Request(link.text)
                # req.set_proxy(
                #    "http-proxy-2.sbb.spk-berlin.de:3128", "http"
                # )  # http-proxy-1.sbb.spk-berlin.de:3128

                try:
                    # urlrequest.urlopen(req)
                    urllib.request.urlopen(link.text)
                except:
                    print("\tfailed")
                else:
                    print("\tsuccess")

    def log(self, msg):
        print(msg)
        logging.info(msg)

    def rmInternalLinks(self):
        """
        SEEMS TO BE NO LONGER NEEDED!

        Remove resourceSet whose linkResource point to internal links (i.e.
        don't beginn with http).
        links are internal if they dont begin with "http", e.g.
        """
        self.log("resourceSet: Removing sets with remaining internal links")
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
        # self.log(
        #    "   LinkChecker: Removing lido records that are not published on recherche.smb"
        # )
        recordsL = self.tree.xpath(
            "/l:lidoWrap/l:lido[not(l:objectPublishedID)]", namespaces=NSMAP
        )
        for recordN in recordsL:
            recID = recordN.xpath("l:lidoRecID", namespaces=NSMAP)[0]
            self.log(f"rm unpublishedRecords: {recID}")
            recordN.getparent().remove(recordN)
        # self.log("rmUnpublishedRecords: done!")

    def saveTree(self):
        self.log(f"Writing back to {self.out_fn}")
        self.tree.write(
            self.out_fn, pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return self.out_fn

    #
    # more private
    #

    def _guess(self, *, link) -> Optional[str]:
        """
        For a given internal linkResource, guess the URL on recherche.smb

        If mulId is already in self.cache, then take the URL from there.

        For some filetypes not URL request is checked, because we already know
        they won't be found (pdf, mp3, tif, tiff).

        EXPECTS
        - link: internal linkResource (i.e. one not starting with http)
          e.g. "1234567.jpg"

        RETURNS
        - public link (on smb.recherche.museum), if it exists, or None
          e.g. https://recherche.smb.museum/images/4305271_1000x600.jpg
        """

        p = Path(link)
        mulId = p.stem
        print(f"_guess: Looking for a public equivalent of linkResource {link}")

        # use link from cache it if exists
        if mulId in self.cache:
            print(" using CACHE")
            return self.cache[mulId]
        # was: try: self.cache[mulId]

        # ignore certain file extensions b/c we know they are not online
        ignore_exts = [".pdf", ".mp3", ".tif", ".tiff"]
        for ext in ignore_exts:
            if p.suffix == ext:
                self.log(f" dont even check for {ext} {p}")
                self.cache[mulId] = None
                return None

        # reasonable possibilities for casing the suffix
        suffixes = set()
        suffixes.add(p.suffix)
        suffixes.add(p.suffix.lower())
        suffixes.add(p.suffix.upper())

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
                    pass
                else:
                    # self.log(f"INFO multimedia {mulId} was FOUND")
                    self.cache[mulId] = new_link
                    return new_link
        # none of the sizes and suffixes yields a match
        self.cache[mulId] = None
        self.log(f" multimedia {mulId} not found")
        return None

    def _save_cache(self):
        with open(self.cacheFn, "w", encoding="utf-8") as f:
            json.dump(self.cache, f, ensure_ascii=False, indent=4)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Simple linkResource checker")
    parser.add_argument(
        "-i",
        "--input",
        help="point to LIDO file",
        required=True,
    )

    parser.add_argument("-v", "--validate", help="validate lido", action="store_true")
    args = parser.parse_args()

    m = LinkChecker(
        Input=args.input,
    )
    m.new_check()
