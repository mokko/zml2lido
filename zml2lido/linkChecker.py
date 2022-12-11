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
from typing import Optional, Union

NSMAP = {"l": "http://www.lido-schema.org"}


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
        self.out_fn = stem + "-2" + ext

        self.relWorksFn = p.parent / "relWorks.cache.xml"
        self.tree = etree.parse(str(Input))

        # new xml cache for fixRelatedWorks
        if Path(self.relWorksFn).exists():
            print(f"   About to load relWorks cache {self.relWorksFn}")
            self.relWorks = Module(tree=etree.parse(self.relWorksFn))
        else:
            print("   starting new relWorks cache file")
            self.relWorks = Module()

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

        client2 = Client2(baseURL=baseURL, user=user, pw=pw)
        
        relatedWorksL = self.tree.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )
        
        self.prepareRelWorksCache(client=client2, relWorksL=relatedWorksL)

        for ID in relatedWorksL:
            # don't log
            # self.log(f"fixRelatedWorks checking {ID.text}")

            # assuming that source always exists
            src = ID.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                modType = "Object"
            elif src == "LIT.ID":
                modType = "Literature"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")

            if ID.text is not None:
                id_str = ID.text
                id_int = int(ID.text)
                # print (f"*****{id_str} {modType}")
                if modType == "Literature":
                    pass
                # print("WARN: No check for modType 'Literature'")
                else:
                    print(f"fixing relatedWork {modType} {id_str}")
                    try:  # is the work already in the cache?
                        relWorkN = self.relWorks[(modType, id_int)]
                    except:  # if not, get record and add it to cache
                        print("   getting item from online RIA")
                        relWork = client2.getItem(modItemId=id_int, modType=modType)
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
                        self.log(f"   removing unpublic relWork")
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

    def prepareRelWorksCache(self, *, client, relWorksL):
        """
        Make a xml cache file with the relatedWorks. It only d/l something
        the first time when the cache file doesn't work yet. For chunks, it
        only caches items from the first chunk.
        """    

        if Path(self.relWorksFn).exists():
            return

        print("   Preparing relWorks cache")
        q = Search(module="Object", limit=-1)

        aset = set()  # no duplicates
        counter = 0
        for ID in relWorksL:
            src = ID.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                modType = "Object"
            elif src == "LIT.ID":
                modType = "Literature"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")
            if ID.text is not None and modType == "Object":
                counter += 1
                id_str = ID.text
                if id_str not in aset:
                    q.addCriterion(
                        operator="equalsField",
                        field="__id",
                        value=id_str,
                    )
                aset.add(id_str)
        if counter > 1:
            #add or retrospectively
            print("xxxxxxxxxxxxx We should use an OR!")
            #q.OR() # only if more than 1
        q.toFile(path="debug-search.xml")
        q.validate(mode="search")
        print("\tprepopulating cache ...")
        self.relWorks = client.search(query=q)
        self.relWorks.toFile(path=self.relWorksFn)
            # print("\tdone")

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
