"""
    parse a LIDO file and work on linkResources that don't start with http 
    for those guess the URL based on heuristics indicated by the examples path below
    write result to lido file in same dir as src
    src and output are lido
    
    This step produces lvl2 lido.

    USAGE:
    lc = LinkChecker(src="path/to/file.lido.xml")

    #related works
    self-relWorks_cache = self.init_relWorks_cache()
    lc.relWorks_cache_single(fn="path/to/file.lido.xml") # parse fn for relWorks and populate cache
    lc.relWorks_cache_many(first="path/to/file.lido.xml") # parse fn for relWorks and populate cache
    lc.fixRelatedWorks() # removes dead links in relatedWorks, also adds ISIL

    lc.linkResource_online_http() # for all linkResources print online status
    lc.rmInternalLinks() # remove linkResource with internal links, not used atm
    lc.rmUnpublishedRecords() # removes objects without objectPublishedID

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

NSMAP = {"l": "http://www.lido-schema.org"}
relWorks_maxSize = 20_000  # more lasts forever
user, pw, baseURL = get_credentials()


class LinkChecker:
    def __init__(self, *, src: str | Path, chunks: bool = False) -> None:
        self._log(f"STATUS: LinkChecker is working on {src}")  # not exactly an error
        self.src = Path(src)
        # self.chunk = chunk
        self.relWorks_fn = self.src.parent / "relWorks.cache.xml"
        self.data = etree.parse(str(src))
        self.client = MpApi(baseURL=baseURL, user=user, pw=pw)
        self.relWorks_cache = self.init_relWorks_cache()  # load file if it exists

        if chunks:
            print("prepare relWorks cache (chunks, many)")
            self.relWorks_cache_many(first=src)  # run only once to make cache
        # why wouldnt I load the first file into the cache?
        else:
            self.relWorks_cache_single(fn=src)

    def fixRelatedWorks(self) -> None:
        """
        Frank doesn't want dead links in relatedWorks. So we loop thru them, check
        if they are SMB-approved (using MpApi) and, if not, we remove them. We're
        also include ISILs in the same step.
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
                    if not self.relWorks_cache.item_exists(mtype=mtype, ID=id_int):
                        self._add_to_relWorks_cache(mtype=mtype, ID=id_int)
                    # at this point we can rely on item being in relWorks cache
                    self._rewrite_relWork(mtype=mtype, objectID=objectID_N)

    def init_relWorks_cache(self) -> Module:
        """
        Initializes self.refWorks cache. If cache file already exists, load it. Else
        initialize empty self.refWorks.
        """
        if Path(self.relWorks_fn).exists():
            # try:
            #    self.relWorks
            # except NameError:
            # print("Inline cache not loaded yet")
            print(f"   Loading existing relWorks cache {self.relWorks_fn}")
            return Module(file=self.relWorks_fn)
            # else:
            # print("Inline cache exists already")
        # if we read relWorks cache from file we dont loop thru data files (chunks)
        # looking for all the relWorks to fill the cache as best as we can
        else:
            print(f"   No relWorks file to load at {self.relWorks_fn}")
            return Module()

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

    def relWorks_cache_many(self, *, first: str | Path) -> None:
        """
        reads relatedWorks into relWorks_cache from all chunks, only until cache is full.

        In case we're in chunk mode, the normal preparation is inefficient, so let's see
        if we can speed things up by offering a separate cache for chunk mode.

        expects
        -first: the path to the first chunk

        TODO: Let's first pass all the relWork.IDs into the set and then make one big
        query. That should be faster. But before we do that, we need to test
        if current version works non-chunk version.

        If the relWorks_cache gets too big (~1GB xml file), split the chunks
        into multiple dirs and process separately.
        """
        ID_cache = set()  # set of relWork ids, no duplicates
        chunk_fn = Path(first)
        # if the cache is already at max_size, we dont do anything
        # else we keep loading more chunks
        if len(self.relWorks) >= relWorks_maxSize:
            return None
        while chunk_fn.exists():
            ID_cache = self._file_to_ID_cache(chunk_fn, ID_cache)
            try:
                chunk_fn = self._nextChunk(fn=chunk_fn)
            except:
                # print ("   breaking the while")
                break  # break the while if this is the only data file or the last chunk
            if len(ID_cache) + len(self.refWorks) >= relWorks_maxSize:
                break
        self._grow_relWorks_cache(ID_cache)

    def relWorks_cache_single(self, *, fn: str | Path) -> None:
        """
        Extracts IDs from one file (fn), queriess RIA for those IDs and adds new info to
        self.relWorks.

        This function currently seems to be so slow that it's useless.
        """
        fn = Path(fn)
        ID_cache = set()  # set of relWork ids, no duplicates
        ID_cache = self._file_to_ID_cache(fn, ID_cache)
        print(f"growing relWorks with ids from {fn}")
        self._grow_relWorks_cache(ID_cache)

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

    def _add_to_relWorks_cache(self, *, mtype: str, ID: int) -> None:
        """
        Get item from RIA, add to relWorks cache and write cache to disk.

        Caution: Does not include a check if relWork is already in cache.
        """
        print(f"   getting item from online RIA {mtype} {ID}")
        # if not, get it now and add to cache
        q = Search(module=mtype, limit=-1)
        q.addCriterion(
            operator="equalsField",
            field="__id",
            value=str(ID),
        )
        q = self._optimize_relWorks_cache(query=q)
        # q.toFile(path="sdata/debug.search.xml")
        relWork = self.client.search2(query=q)
        if relWork:  # realistic that query results are empty?
            # appending them to relWork cache
            self.relWorks_cache += relWork
            # print ("   update file cache")
            self.relWorks_cache.toFile(path=self.relWorks_fn)

    def _del_relWork(self, *, ID) -> None:
        """
        delete a relWork from self.etree.
        ID is a lxml node
        """
        self._log(f"   removing unpublic relWork {ID.text}")
        relWorkSet = ID.getparent().getparent().getparent()
        relWorkSet.getparent().remove(relWorkSet)

    def _file_to_ID_cache(self, chunk_fn: Path, ID_cache: set) -> set:
        """
        Given the path to a lido file, scan it for relWorks and produce a set with the
        objIds.

        ID is a lxml node
        """
        print(f"   _file_to_ID_cache exists {chunk_fn}")
        chunkET = etree.parse(str(chunk_fn))

        relWorksL = chunkET.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        print(f"   _file_to_ID_cache {len(relWorksL)} relWorks")

        for ID in relWorksL:
            src = ID.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                mType = "Object"
            elif src == "LIT.ID":
                mType = "Literature"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")

            # dont write more than a few thousand items in cache
            # if len(ID_cache) >= relWorks_maxSize:
            #    print("break here")
            #    break
            if ID.text is not None and mType == "Object":
                # only add this to ID_cache if not yet in relWorks cache
                objId = int(ID.text)
                if not self.relWorks_cache.item_exists(mtype="Object", ID=objId):
                    ID_cache.add(objId)
        print(f"   adding {len(ID_cache)} IDs")
        return ID_cache

    def _grow_relWorks_cache(self, ID_cache: set) -> None:
        """
        Make one query with all the IDs from ID_cache, execute the query and save the results
        to self.relWorks, also write to disk
        """
        print(
            f"   _grow_relWorks_cache: new IDs: {len(ID_cache)} relWorks:{len(self.relWorks_cache)}"
        )
        if len(ID_cache) > 0:
            q = Search(module="Object", limit=-1)
            if len(ID_cache) > 1:
                q.OR()  # only or if more than 1

            for id_ in sorted(ID_cache):
                q.addCriterion(
                    operator="equalsField",
                    field="__id",
                    value=str(id_),
                )
            q = self._optimize_relWorks_cache(query=q)
            # q.toFile(path="sdata/debug.search.xml")
            print(
                f"   populating relWorks cache {len(ID_cache)} (max size {relWorks_maxSize})"
            )
            newRelWorksM = self.client.search2(query=q)
            try:
                self.relWorks
            except:
                # make a new cache (might be faster than adding to it)
                self.relWorks = newRelWorksM
            else:
                # if relWorks exists already, add to it
                print("   adding")
                self.relWorks += newRelWorksM
            # save the cache to file after processing every chunk
            # no max_size limitation
            self.relWorks.toFile(path=self.relWorks_fn)

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

    def _nextChunk(self, *, fn: str | Path) -> Path:
        """
        Returns the path/name of the next chunk if it exists or errors if the src
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
                raise FileNotFoundError(f"ERROR: chunk does not exist '{new_path}'")
        else:
            raise SyntaxError("ERROR: Filename not chunkable")

    def _optimize_relWorks_cache(self, *, query: Search) -> Search:
        """
        let's shrink (optimize) the xml. We only need a couple fields
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

    def _relWork_online(self, *, mtype: str, modItemId: int) -> bool:
        """
        Checks if a specific relWork is online. No urlrequest, just examins if
        SMB-Freigabe = Ja.

        Expects modItemId as int; but str should work as well.
        """
        r = self.relWorks_cache.xpath(
            f"""/m:application/m:modules/m:module[
                @name = '{mtype}']/m:moduleItem[
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

    def _rewrite_relWork(self, *, mtype: str, objectID: Any) -> None:
        """
        if relWork unpublic, delete it from lvl2 lido file; otherwise rewrite relWork using ISIL
        """
        id_int = int(objectID.text)

        # we can rely on item being in cache, says I
        try:
            relWorkM = self.relWorks_cache[(mtype, id_int)]
        except:
            print(f"WARNING: no relWork found for {mtype} {id_int}")

        if self._relWork_online(mtype=mtype, modItemId=id_int):
            # rewrite ISIL, should look like this:
            # <lido:objectID lido:type="local" lido:source="ISIL/ID">de-MUS-018313/744501</lido:objectID>
            # self._log(f"   looking up ISIL for relWork")
            objectID.attrib["{http://www.lido-schema.org}source"] = "ISIL/ID"
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
                objectID.text = f"{ISIL}/{str(id_int)}"
                print(f"   relWork {id_int}: {verwInst.text} -> {ISIL}")
        else:
            self._del_relWork(ID=objectID)  # rm from lido lvl2


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
