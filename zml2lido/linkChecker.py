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
from mpapi.constants import get_credentials
from mpapi.client import MpApi
from mpapi.module import Module
from mpapi.search import Search
from pathlib import Path
import re
from typing import Optional, Union

NSMAP = {"l": "http://www.lido-schema.org"}
relWorksMaxSize = 40000
user, pw, baseURL = get_credentials()


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
        # we used to not prepare the relWorksCache here. Why?
        print("prepare relWorks cache")
        self.prepareRelWorksCache2(first=Input)  # run only once to make cache

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

        client = MpApi(baseURL=baseURL, user=user, pw=pw)

        relatedWorksL = self.tree.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        # for //relatedWork in the current LIDO document
        for ID in relatedWorksL:
            # don't log self.log(f"fixRelatedWorks checking {ID.text}")

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
                id_int = int(ID.text)
                # only recursive should get us here
                # except:
                #    id_int = int(ID.text.split("/")[-1])
                # print (f"*****{id_str} {modType}")
                if modType == "Literature":
                    pass
                    # print("WARN: No check for modType 'Literature'")
                else:
                    # print(f"fixing relatedWork {modType} {id_int}")
                    try:
                        # is the work already in the cache?
                        relWorkN = self.relWorks[(modType, id_int)]
                    except:  # if not, get record and add it to cache
                        print("   getting item from online RIA")
                        # if not, get it now and add to cache
                        q = Search(module=modType, limit=-1)
                        q.addCriterion(
                            operator="equalsField",
                            field="__id",
                            value=str(id_int),
                        )
                        q = self._optimize_relWorks_cache(query=q)
                        # q.toFile(path="sdata/debug.search.xml")
                        relWork = client.search2(query=q)
                        if relWork:  # realistic that query results are empty?
                            # appending them to relWork cache
                            self.relWorks += relWork
                            # print ("   update file cache")
                            self.relWorks.toFile(path=self.relWorksFn)
                    else:
                        # if relWork record is already in cache
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
                        ID.text = f"{ISIL}/{str(id_int)}"
                        print(f"   relWork: {id_int}:{verwInst.text} -> {ISIL}")
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

        # used to re-read the file cache multiple times
        if Path(self.relWorksFn).exists():
            try:
                self.relWorks
            except:
                # print("Inline cache not loaded yet")
                print(f"   About to load existing relWorks cache {self.relWorksFn}")
                self.relWorks = Module(file=self.relWorksFn)
                return
                # if we read relWorks cache from file we dont loop thru data files (chunks)
                # looking for all the relWorks to fill the cache as best as we can
            else:
                print("Inline cache exists already")
        else:
            print(f"   No existing relWorks cache at {self.relWorksFn}")

        cacheOne = set()  # set of relWork ids, no duplicates
        chunk_fn = Path(first)
        while chunk_fn.exists():
            print(f"   data file (may be a chunk) exists {chunk_fn}")
            chunkET = etree.parse(str(chunk_fn))

            relWorksL = chunkET.xpath(
                """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
                l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
                namespaces=NSMAP,
            )

            print(f"   chunk has {len(relWorksL)} relWorks")

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
                    cacheOne.add(int(ID.text))
            try:
                chunk_fn = self._nextChunk(fn=chunk_fn)
            except:
                # print ("   breaking the while")
                break  # break the while if this is the only data file or the last chunk

        print(f"   Length of cacheOne: {len(cacheOne)}")
        client = MpApi(baseURL=baseURL, user=user, pw=pw)
        if len(cacheOne) > 0:
            q = Search(module="Object", limit=-1)
            if len(cacheOne) > 1:
                q.OR()  # only or if more than 1

            for id_ in sorted(cacheOne):
                q.addCriterion(
                    operator="equalsField",
                    field="__id",
                    value=str(id_),
                )
            q = self._optimize_relWorks_cache(query=q)
            # q.toFile(path="sdata/debug.search.xml")
            print(
                f"   populating relWorks cache {len(cacheOne)} (max size {relWorksMaxSize})"
            )
            newRelWorksM = client.search2(query=q)
            # if the inline cache already exists
            try:
                self.relWorks
            except:
                # make a new inline cache (might be faster than adding to it)
                self.relWorks = newRelWorksM
            else:
                # if relWorks exists already, add to it
                self.relWorks += newRelWorksM
            # save the inline cache to file after processing every chunk
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
        self.log("rmUnpublishedRecords: done!")

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
        Returns the path/name of the next chunk if it exists or errors if the input
        is not chunkable or the next chunk does not exist.

        Expects path/name of lvl 1 lido file that ends in ".lido.xml".
        """
        stem = str(fn).split(".lido.xml")[0]
        m = re.search(r"-chunk(\d+)$", stem)
        if m:
            no = int(m.group(1))
            new_no = no + 1
            no_no = re.sub(r"\d+$", "", stem)
            new_path = Path(f"{no_no}{new_no}.lido.xml")
            # print(f"D: Suggested new path: {new_path}")
            if Path(new_path).exists():
                return new_path
            else:
                raise FileNotFoundError("chunk does not exist")
        else:
            raise SyntaxError("not chunkable")

    def _optimize_relWorks_cache(self, *, query):
        """
        let's shrink (optimize) the xml. We only need two fields
        (1) ObjOwnerRef (=verwaltendeInstitution)
        (2) ObjPublicationGrp for online status
        """
        query.addField(field="__lastModified")  # for mpapi.add
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
