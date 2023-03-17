"""
    parse a LIDO file for linkResources and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as input
    input and output are lido
    
    https://recherche.smb.museum/images/5403567_2500x2500.jpg
    lidoWrap/lido/administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource
"""

import json
import logging
from lxml import etree
from mpapi.client2 import Client2
from mpapi.module import Module
from mpapi.search import Search
from pathlib import Path
import re
from typing import Optional, Union

NSMAP = {"l": "http://www.lido-schema.org"}
relWorksMaxSize = 65000
cred_fn = "sdata/credentials.py"

if Path(cred_fn).exists():  # some things like saxon should run even
    with open(cred_fn) as f:  # credentials are not where expected
        exec(f.read())


class LinkChecker:
    def __init__(self, *, Input):
        self.log(f"LinkChecker is working on {Input}")  # not exactly an error
        # determine out_fn
        p = Path(Input)
        ext = "".join(p.suffixes)
        stem = str(p).split(".")[0]
        self.out_fn = stem + "-2" + ext  # name and location for python transformation

        self.relWorksFn = p.parent / "relWorks.cache.xml"
        self.tree = etree.parse(str(Input))

    def checkRelWorkOnline(self, *, modType: str, modItemId: int):
        """
        Checks if a specific relWork is online. No urlrequest, just examins if
        SMB-Freigabe = Ja.

        Expects modItemId as int; but str should work as well.
        """
        r = self.relWorks.xpath(
            f"""/m:application/m:modules/m:module[
                @name = '{modType}']/m:moduleItem[
                @id = {str(modItemId)}]/m:repeatableGroup[
                @name = 'ObjPublicationGrp']/m:repeatableGroupItem[
                    m:vocabularyReference[@name='PublicationVoc']/m:vocabularyReferenceItem[@name='Ja'] 
                    and m:vocabularyReference[@name='TypeVoc']/m:vocabularyReferenceItem[@id = 2600647]
                ]"""
        )
        if len(r) > 0:
            return True
        else:
            return False

    def fixRelatedWorks(self):
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if they are SMB-approved (using MpApi) and, if not, we remove them. We're
        also include ISILs in the same step.
        """

        self.log(
            "fixRelatedWorks: Removing relatedWorks that are not online and getting ISILs"
        )

        client = Client2(baseURL=baseURL, user=user, pw=pw)

        relatedWorksL = self.tree.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        for ID in relatedWorksL:
            # don't log
            # self.log(f"fixRelatedWorks checking {ID.text}")

            # assuming that source always exists
            src = ID.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                modType = "Object"
            elif src == "LIT.ID":
                modType = "Literature"
            elif src == "ISIL/ID":
                raise ValueError(
                    "ERROR: @lido:source='ISIL/ID' indicates that an already"
                    + "processed LIDO file is being processed again"
                )
                modType = "Object"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")

            if ID.text is not None:
                id_str = ID.text
                # try:
                id_int = int(ID.text)
                # only recursive should get us here
                # except:
                #    id_int = int(ID.text.split("/")[-1])
                # print (f"*****{id_str} {modType}")
                if modType == "Literature":
                    pass
                # print("WARN: No check for modType 'Literature'")
                else:
                    # print(f"fixing relatedWork {modType} {id_str}")
                    try:  # is the work already in the cache?
                        relWorkN = self.relWorks[(modType, id_int)]
                    except:  # if not, get record and add it to cache
                        print("   getting item from online RIA")
                        # we're getting whole documents here and
                        # relWork = client.getItem(modItemId=id_int, modType=modType)
                        q = Search(module=modType, limit=-1)
                        q.addCriterion(
                            operator="equalsField",
                            field="__id",
                            value=str(id_int),
                        )
                        q = self._optimize_relWorks_cache(query=q)
                        # q.toFile(path="sdata/debug.search.xml")
                        relWorks = client.search(query=q)

                        # appending them to relWork cache
                        self.relWorks += relWork
                        # print ("   update file cache")
                        self.relWorks.toFile(path=self.relWorksFn)
                    else:
                        # print("   taking from cache")
                        # success message dont need logging
                        relWork = Module()
                        relWork.addItem(itemN=relWorkN, mtype=modType)

                    if self.checkRelWorkOnline(modType=modType, modItemId=id_int):
                        # rewrite ISIL, should look like this:
                        # <lido:objectID lido:type="local" lido:source="ISIL/ID">de-MUS-018313/744501</lido:objectID>
                        # self.log(f"   looking up ISIL for relWork")
                        ID.attrib["{http://www.lido-schema.org}source"] = "ISIL/ID"
                        # we're assuming there is always a verwaltendeInstitution, but that is not enforced by RIA!
                        verwInst = relWork.xpath(
                            """//m:moduleReference[
                                @name='ObjOwnerRef'
                            ]/m:moduleReferenceItem/m:formattedValue"""
                        )[0]
                        ISIL = self.ISIL_lookup(institution=verwInst.text)
                        ID.text = f"{ISIL}/{id_str}"
                        print(f"   relWork: {id_str}:{verwInst.text} -> {ISIL}")
                    else:
                        # self.log(f"   removing unpublic relWork")
                        relWorkSet = ID.getparent().getparent().getparent()
                        relWorkSet.getparent().remove(relWorkSet)

    def ISIL_lookup(self, *, institution):
        """
        Load vocmap.xml and lookup ISIL for name of institution.

        In the beginning, we die when no ISIL found, but later we might carp more gracefully.
        """
        vm_fn = Path(__file__).parents[1] / "vocmap.xml"
        if not vm_fn.exists():
            raise SyntaxError(f"File not found {vm_fn}")
        vocMap = etree.parse(vm_fn)
        try:
            ISIL = vocMap.xpath(
                f"""/vocmap/voc[
                @name='verwaltendeInstitution'
            ]/concept[
                source = '{institution}'
            ]/target[
                @name = 'ISIL'
            ]"""
            )[0]
        except:
            raise SyntaxError(
                f"vocMap: verwaltendeInstitution '{institution}' not found"
            )
        return ISIL.text

    def log(self, msg):
        print(msg)
        logging.info(msg)

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

    def prepareRelWorksCache2(self, *, first):
        """
        creates relatedWorksCache from all chunks

        In case, we in chunk mode, the normal preparation is inefficient, so let's see
        if we can speed things up by offering a separate cache for chunk mode

        expects
        -first: the path to the first chunk (as str or Path)

        TODO: Let's first pass all the relWork.IDs into the set and then make one big
        query. That should be faster. But before we do that, we need to test
        if current version works non-chunk version.

        If the relWorksCache gets too big (~1GB xml file), split the chunks
        into multiple dirs and process separately.
        """

        if Path(self.relWorksFn).exists():
            print(f"   About to load relWorks cache {self.relWorksFn}")
            self.relWorks = Module(file=self.relWorksFn)
            return

        client = Client2(baseURL=baseURL, user=user, pw=pw)
        cacheOne = set()  # no duplicates
        chunk_fn = Path(first)
        while chunk_fn.exists():
            print(f"   1st relWorks cache {chunk_fn}")
            chunkET = etree.parse(str(chunk_fn))

            relWorksL = chunkET.xpath(
                """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
                l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
                namespaces=NSMAP,
            )

            for ID in relWorksL:
                src = ID.xpath("@l:source", namespaces=NSMAP)[0]
                if src == "OBJ.ID":
                    modType = "Object"
                elif src == "LIT.ID":
                    modType = "Literature"
                else:
                    raise ValueError(f"ERROR: Unknown type: {src}")

                # dont write more than a few thousand items in cache
                if len(cacheOne) >= relWorksMaxSize:
                    break
                if ID.text is not None and modType == "Object":
                    cacheOne.add(ID.text)
            chunk_fn = self._nextChunk(fn=chunk_fn)
            if chunk_fn == first:
                break  # if it's still the original path, we break the while

        if len(cacheOne) > 1:
            q = Search(module="Object", limit=-1)
            q.OR()  # only or if more than 1

            for id_str in sorted(cacheOne):
                q.addCriterion(
                    operator="equalsField",
                    field="__id",
                    value=id_str,
                )
            q = self._optimize_relWorks_cache(query=q)
            q.toFile(path="sdata/debug.search.xml")
            print(
                f"   populating relWorks cache {len(cacheOne)} (max size {relWorksMaxSize})"
            )
            newRelWorksM = client.search(query=q)
            if hasattr(self, "relWorks"):
                print(f"\tadding ...")
                self.relWorks += newRelWorksM
            else:
                self.relWorks = newRelWorksM  # might be faster
            self.relWorks.toFile(path=self.relWorksFn)

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
        """
        During __init__ we loaded a LIDO file, with this function we write it back to the
        out file location as set during __init__.
        """
        self.log(f"Writing back to {self.out_fn}")
        self.tree.write(
            self.out_fn, pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return self.out_fn

    #
    #
    #

    def _nextChunk(self, *, fn: Path):
        """
        Returns the path/name of the next chunk if possible; if it is
        given some other path that it doesn't expect, it returns the
        original path it has been given initially.

        Expects path/name of lvl 1 lido file that ends in ".lido.xml".
        """
        stem = str(fn).split(".lido.xml")[0]
        m = re.search("-chunk(\d+)$", stem)
        if m:
            no = int(m.group(1))
            new_no = no + 1
            no_no = re.sub("\d+$", "", stem)
            new_path = Path(f"{no_no}{new_no}.lido.xml")
            # print(f"D: Suggested new path: {new_path}")
            return new_path
        else:
            print("D: CHUNK NOT FOUND!")
            return fn

    def _optimize_relWorks_cache(self, *, query):
        """
        let's shrink (optimize) the xml. We only need two fields
        (1) ObjOwnerRef (=verwaltendeInstitution)
        (2) ObjPublicationGrp for online status
        """
        query.addField(field="ObjOwnerRef")
        query.addField(field="ObjOwnerRef.moduleReferenceItem")
        query.addField(field="ObjOwnerRef.formattedValue")
        query.addField(field="ObjPublicationGrp")
        query.addField(field="ObjPublicationGrp.repeatableGroupItem")
        query.addField(field="ObjPublicationGrp.PublicationVoc")
        query.addField(field="ObjPublicationGrp.TypeVoc")
        query.validate(mode="search")
        return query


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
