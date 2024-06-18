"""
parse a LIDO file and work on linkResources that don't start with http
for those guess the URL based on heuristics indicated by the examples path below
write result to lido file in same dir as src
src and output are lido

This step produces lvl2 lido.

USAGE:
lc = LinkChecker(src=path/to/file.lido.xml") # accepts path as string
lc.load_lvl1(src=path)
lc.fixRelatedWorks()          # removes dead links in relatedWorks, also adds ISIL
lc.linkResource_online_http() # for all linkResources print online status
lc.rmInternalLinks()          # remove linkResource with internal links, not used atm
lc.rmUnpublishedRecords()     # removes objects without objectPublishedID

lc.save(lvl2="path/to/lido.lvl2.xml")

"""

import logging
from lxml import etree
from mpapi.constants import get_credentials
from mpapi.client import MpApi
from pathlib import Path
from typing import Any
import urllib.request
from zml2lido.relWorksCache import RelWorksCache

# from zml2lido import NSMAP
NSMAP = {"l": "http://www.lido-schema.org"}

rescan_lvl1_files_at_init = False


class LinkChecker:
    def __init__(self, *, src: Path, chunks: bool = False) -> None:
        logging.debug(
            f"STATUS: LinkChecker is working on {src}"
        )  # not exactly an error
        # self.chunk = chunk
        self.chunks = chunks
        user, pw, baseURL = get_credentials()
        self.client = MpApi(baseURL=baseURL, user=user, pw=pw)
        cache_dir = src.parent
        self.rwc = RelWorksCache(maxSize=20_000, cache_dir=cache_dir)
        self.rwc.load_cache_file()  # load file if it exists once atb

        if rescan_lvl1_files_at_init:
            # run only once to update cache
            if self.chunks:
                print("prepare relWorks cache (chunks, many)")
                self.rwc.lookup_from_lido_chunks(path=Path(src))
            else:
                self.rwc.lookup_from_lido_file(path=Path(src))

    def fixRelatedWorks(self) -> None:
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if they are SMB-approved (using MpApi) and, if not, we remove them. We're
        also include ISILs in the same step.

        relWork's objectID is at relWork/object/objectID
        """
        logging.debug(
            "fixRelatedWorks: Removing relatedWorks that are not online and getting ISILs"
        )

        relatedWorksL = self.data.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        # for //relatedWork in the current LIDO document
        for idx, objectID_N in enumerate(relatedWorksL):
            # don't _log logging.debug(f"fixRelatedWorks checking {objectID_N.text}")

            # assuming that source always exists
            src = objectID_N.xpath("@l:source", namespaces=NSMAP)[0]
            # print (f"fixRelatedWorks {idx}/{len(relatedWorksL)} {src} {objectID_N.text}")
            match src:
                case "OBJ.ID":
                    mtype = "Object"
                case "LIT.ID":
                    mtype = "Literature"
                case "ISIL/ID":
                    # conceivable that lxml processes some nodes multiple times
                    # this seems to happen when we change lxml tree without making a deepcopy
                    logging.warning(
                        "WARN: 'ISIL/ID' indicates that processing a LIDO file for a second time"
                    )
                    mtype = "rewritten"  # fake case
                case _:
                    raise ValueError(f"ERROR: Unknown type: '{src}'")

            if objectID_N.text is not None:
                try:
                    id_int = int(objectID_N.text)
                except ValueError:
                    id_int = None
                print(f"relatedWork {idx}/{len(relatedWorksL)} {mtype} {id_int}")
                if mtype == "Object" and id_int is not None:
                    if not self.rwc.item_exists(mtype=mtype, ID=id_int):
                        self.rwc.lookup_relWork(mtype=mtype, ID=id_int)
                    self._rewrite_relWork(mtype=mtype, objectID_N=objectID_N)
                else:
                    print(
                        f"{idx}/{len(relatedWorksL)}{objectID_N.text} already rewritten"
                    )
            if idx % 100:
                self.rwc.save_if_changed()

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

    def load_lvl1(self, *, src: Path) -> None:
        self.data = etree.parse(str(src))

    def rmInternalLinks(self) -> None:
        """
        Remove resourceSet whose linkResource point to internal links;
        links are internal if they dont begin with "http", e.g.

        Not currently used.
        """
        logging.debug("resourceSet: Removing sets with remaining internal links")
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
        # logging.debug(
        #    "   LinkChecker: Removing lido records that are not published on recherche.smb"
        # )
        recordsL = self.data.xpath(
            "/l:lidoWrap/l:lido[not(l:objectPublishedID)]", namespaces=NSMAP
        )
        for recordN in recordsL:
            recID = recordN.xpath("l:lidoRecID", namespaces=NSMAP)[0]
            logging.debug(f"rm unpublishedRecords: {recID}")
            recordN.getparent().remove(recordN)
        logging.debug("rmUnpublishedRecords: done!")

    def save(self, *, lvl2: Path) -> Path:
        """
        During __init__ we loaded a LIDO file, with this function we write it back to the
        out file location as set during __init__.
        """
        logging.debug(f"Writing back to {lvl2}")
        self.data.write(
            str(lvl2), pretty_print=True, encoding="UTF-8", xml_declaration=True
        )
        return lvl2

    #
    # PRIVATE
    #

    def _del_relWork(self, *, ID_N: Any) -> None:
        """
        delete a relWork from self.etree.
        ID is a lxml node
        """
        # logging.debug(f"   removing unpublic relWork {ID_N.text}")
        relWorkSet = ID_N.getparent().getparent().getparent()
        relWorkWrap = relWorkSet.getparent()
        relWorkWrap.remove(relWorkSet)
        resL = relWorkWrap.xpath("l:relatedWorkSet", namespaces=NSMAP)
        if len(resL) == 0:
            # logging.info("removing empty relWorkWrap")
            relWorkWrap.getparent().remove(relWorkWrap)

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
            relWorkM = self.rwc.get_item(mtype=mtype, ID=id_int)
        except:
            logging.WARNING(f"WARNING: no relWork found for {mtype} {id_int}")

        if self.rwc.item_is_online(mtype=mtype, ID=id_int):
            # rewrite ISIL, should look like this:
            # <lido:objectID lido:type="local" lido:source="ISIL/ID">de-MUS-018313/744501</lido:objectID>
            # logging.debug(f"   looking up ISIL for relWork")
            objectID_N.attrib["{http://www.lido-schema.org}source"] = "ISIL/ID"
            # we're assuming there is always a verwaltendeInstitution, but that is not enforced by RIA!
            try:
                verwInst = relWorkM.xpath(
                    """//m:moduleReference[
                        @name='ObjOwnerRef'
                    ]/m:moduleReferenceItem/m:formattedValue"""
                )[0]
            except:
                logging.WARNING(
                    f"WARNING: verwaltendeInstitution empty! {mtype} {id_int}"
                )
            else:
                ISIL = self._lookup_ISIL(institution=verwInst.text)
                objectID_N.text = f"{ISIL}/{str(id_int)}"
                # logging.debug(f"   relWork {id_int}: {verwInst.text} -> {ISIL}")
                # print(f"_rewrite_relWork {mtype} {id_int} rewrite ok")
        else:
            self._del_relWork(ID_N=objectID_N)  # rm from lido lvl2
            # print(f"_rewrite_relWork {mtype} {id_int} not online")


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
