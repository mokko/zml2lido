"""
    parse a LIDO file and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as src
    src and output are lido
    
    This step produces lvl2 lido.

    USAGE:
    lc = LinkChecker(src="path/to/file.lido.xml")

    lc.fixRelatedWorks()          # removes dead links in relatedWorks, also adds ISIL
    lc.linkResource_online_http() # for all linkResources print online status
    lc.rmInternalLinks()          # remove linkResource with internal links, not used atm
    lc.rmUnpublishedRecords()     # removes objects without objectPublishedID

    lc.save(out_fn="path/to/lido.lvl2.xml")

"""

import logging
from lxml import etree
from mpapi.constants import get_credentials
from mpapi.client import MpApi
from mpapi.module import Module
from mpapi.search import Search
from pathlib import Path
import re
from typing import Any
import urllib.request
from zml2lido.relWorksCache import RelWorksCache
# from zml2lido import NSMAP


class LinkChecker:
    def __init__(self, *, src: str | Path, chunks: bool = False) -> None:
        self._log(f"STATUS: LinkChecker is working on {src}")  # not exactly an error
        # self.chunk = chunk
        self.data = etree.parse(str(src))
        user, pw, baseURL = get_credentials()
        self.client = MpApi(baseURL=baseURL, user=user, pw=pw)
        self.rwc = RelWorksCache(maxSize=20_000)
        self.rwc.load_cache_file()  # load file if it exists

        if chunks:
            print("prepare relWorks cache (chunks, many)")
            self.rwc.lookup_from_lido_chunks(path=Path(src))
        else:
            self.rwc.lookup_from_lido_file(
                path=Path(src)
            )  # run only once to make cache

    def fixRelatedWorks(self) -> None:
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if they are SMB-approved (using MpApi) and, if not, we remove them. We're
        also include ISILs in the same step.

        relWork's objectID is at relWork/object/objectID
        """
        self._log(
            "fixRelatedWorks: Removing relatedWorks that are not online and getting ISILs"
        )

        relatedWorksL = self.data.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        # for //relatedWork in the current LIDO document
        for objectID_N in relatedWorksL:
            # don't _log self._log(f"fixRelatedWorks checking {objectID_N.text}")

            # assuming that source always exists
            src = objectID_N.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                mtype = "Object"
            elif src == "LIT.ID":
                mtype = "Literature"
            elif src == "ISIL/ID":
                raise ValueError(
                    "ERROR: @lido:source='ISIL/ID' indicates that an already "
                    + "processed LIDO file is being processed again"
                )
                mtype = "Object"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")

            if objectID_N.text is not None:
                id_int = int(objectID_N.text)
                if mtype == "Literature":
                    pass
                    # print("WARN: No check for mtype 'Literature'")
                else:
                    # print(f"fixing relatedWork {mtype} {id_int}")
                    if not self.rwc.item_exists(mtype=mtype, ID=id_int):
                        self.rwc.lookup_relWork(mtype=mtype, ID=id_int)
                    # at this point we can rely on item being in relWorks cache
                    self._rewrite_relWork(mtype=mtype, objectID_N=objectID_N)

    def linkResource_online_http(self) -> None:
        """
        For all linkResources in self.data, check if url responds ok using http.
        Prints the result (which is a bit awkward).
        """
        linkResourceL = self.data.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )

        print("NEW CHECKER")
        for linkN in linkResourceL:
            if linkN.text is not None:
                print(linkN.text)
                # req = urlrequest.Request(linkN.text)
                # req.set_proxy(
                #    "http-proxy-2.sbb.spk-berlin.de:3128", "http"
                # )  # http-proxy-1.sbb.spk-berlin.de:3128

                try:
                    # urlrequest.urlopen(req)
                    urllib.request.urlopen(linkN.text)
                except:
                    print("\tfailed")
                else:
                    print("\tsuccess")

    def rmInternalLinks(self) -> None:
        """
        Remove resourceSet whose linkResource point to internal links;
        links are internal if they dont begin with "http", e.g.

        Not currently used.
        """
        self._log("resourceSet: Removing sets with remaining internal links")
        linkResourceL = self.data.xpath(
            "/l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource",
            namespaces=NSMAP,
        )
        for link in linkResourceL:
            if link.text is not None:  # empty links seem to be new?
                if not link.text.startswith("http"):
                    resourceSet = link.getparent().getparent()
                    resourceSet.getparent().remove(resourceSet)

    def rmUnpublishedRecords(self) -> None:
        """
        Remove lido records which are not published on SMB Digital.

        Assumes that only records which have SMBFreigabe=Ja have objectPublishedID
        """
        # self._log(
        #    "   LinkChecker: Removing lido records that are not published on recherche.smb"
        # )
        recordsL = self.data.xpath(
            "/l:lidoWrap/l:lido[not(l:objectPublishedID)]", namespaces=NSMAP
        )
        for recordN in recordsL:
            recID = recordN.xpath("l:lidoRecID", namespaces=NSMAP)[0]
            self._log(f"rm unpublishedRecords: {recID}")
            recordN.getparent().remove(recordN)
        self._log("rmUnpublishedRecords: done!")

    def save(self, out_fn: str | Path) -> str:
        """
        During __init__ we loaded a LIDO file, with this function we write it back to the
        out file location as set during __init__.
        """
        self._log(f"Writing back to {out_fn}")
        self.data.write(
            str(out_fn), pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return out_fn

    #
    # PRIVATE
    #

    def _del_relWork(self, *, ID_N: Any) -> None:
        """
        delete a relWork from self.etree.
        ID is a lxml node
        """
        self._log(f"   removing unpublic relWork {ID_N.text}")
        relWorkSet = ID_N.getparent().getparent().getparent()
        relWorkSet.getparent().remove(relWorkSet)

    def _log(self, msg: str) -> None:
        print(msg)
        logging.info(msg)

    def _lookup_ISIL(self, *, institution) -> str:
        """
        Load vocmap.xml and lookup ISIL for name of institution.

        In the beginning, we die when no ISIL found, but later we might carp more gracefully.
        """
        vm_fn = Path(__file__).parents[1] / "vocmap.xml"
        if not vm_fn.exists():
            raise SyntaxError(f"ERROR: vocmap file not found {vm_fn}")
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

    def _rewrite_relWork(self, *, mtype: str, objectID_N: Any) -> None:
        """
        if relWork unpublic, delete it from lvl2 lido file; otherwise rewrite relWork using ISIL
        """
        id_int = int(objectID_N.text)

        # we can rely on item being in cache, says I
        try:
            relWorkM = self.rwc.item_exists(mtype=mtype, ID=id_int)
        except:
            print(f"WARNING: no relWork found for {mtype} {id_int}")

        if self.rwc.item_is_online(mtype=mtype, ID=id_int):
            # rewrite ISIL, should look like this:
            # <lido:objectID lido:type="local" lido:source="ISIL/ID">de-MUS-018313/744501</lido:objectID>
            # self._log(f"   looking up ISIL for relWork")
            objectID_N.attrib["{http://www.lido-schema.org}source"] = "ISIL/ID"
            # we're assuming there is always a verwaltendeInstitution, but that is not enforced by RIA!
            try:
                verwInst = relWorkM.xpath(
                    """//m:moduleReference[
                        @name='ObjOwnerRef'
                    ]/m:moduleReferenceItem/m:formattedValue"""
                )[0]
            except:
                self._log(f"WARNING: verwaltendeInstitution empty! {mtype} {id_int}")
            else:
                ISIL = self._lookup_ISIL(institution=verwInst.text)
                objectID_N.text = f"{ISIL}/{str(id_int)}"
                print(f"   relWork {id_int}: {verwInst.text} -> {ISIL}")
        else:
            self._del_relWork(ID_N=objectID_N)  # rm from lido lvl2


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Simple linkResource checker")
    parser.add_argument(
        "-i",
        "--src",
        help="point to LIDO file",
        required=True,
    )

    parser.add_argument("-v", "--validate", help="validate lido", action="store_true")
    args = parser.parse_args()

    m = LinkChecker(
        src=args.src,
    )
    m.linkResource_online_http()
