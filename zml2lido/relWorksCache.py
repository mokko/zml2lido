"""
    cache information about related Works (relWorks)

    Most importantly, we want to know whether relWorks are online or not. So we query
    RIA and save the information (SMB-Freigabe) in a Module object and potentially the disk.

    rw = relWorks(maxSize=20_000) #
    rw.load_cache_file(path=Path("cache.xml")) # load cache file or nothing

    rw.lookup_relWork(mtype, ID)? # lookup a single item in RIA and add it to cache.
    rw.lookup_from_lido_file(path=path) # grow cache by new items from a single file
    rw.lookup_from_lido_chunks(path=path) # grow cache by new items from a single file

    rw.item_exists(mtype="Object", ID=1234) # true if item exists in cache
    rw.item_is_online(mtype="Object", ID=1234) # true if item in cache indicates it's online

    rw.save() # save in-memory cache to disk

Currently: we NOT respect max_size?

How do we delete items from cache if the maxSize is reached?



"""

from lxml import etree
from mpapi.constants import get_credentials
from mpapi.client import MpApi
from mpapi.module import Module
from mpapi.search import Search
from pathlib import Path
from zml2lido.file import per_chunk

# from zml2lido import NSMAP
NSMAP = {"l": "http://www.lido-schema.org"}


class RelWorksCache:
    def __init__(self, *, maxSize: int = 20_000, cache_dir: Path) -> None:
        self.cache = Module()
        self.maxSize = maxSize
        self.cache_path = cache_dir / "relWorks_cache.xml"

        user, pw, baseURL = get_credentials()
        self.client = MpApi(baseURL=baseURL, user=user, pw=pw)

    def lookup_from_lido_chunks(self, *, path: Path) -> None:
        """
        Like 'lookup_from_lido_file', except that multiple chunks are processed;
        this requires the chunks to be named appropriately.
        """
        for p in per_chunk(path=path):
            self.lookup_from_lido_file(path=p)

    def lookup_from_lido_file(self, *, path: Path) -> None:
        """
        Parse a lido (lvl1) file for relWorks, query RIA and add the results to
        the cache.

        Should we check that we don't process a lido lvl2 file that has already
        been processed?
        """
        IDs = self._lido_to_ids(path=path)
        for mtype, id_int in IDs:
            self.lookup_relWork(mtype=mtype, ID=id_int)

    def lookup_relWork(self, *, mtype: str, ID: int) -> None:
        """
        Lookup a single relatedWork (relWork) in RIA and write it to in-memory cache.
        Even if it exceeds the cache size.
        """
        q = Search(module=mtype, limit=-1)
        q.addCriterion(
            operator="equalsField",
            field="__id",
            value=str(ID),
        )
        q = self._optimize_query(query=q)
        relWorkM = self.client.search2(query=q)
        if relWorkM:  # realistic that query results are empty?
            self.cache += relWorkM  # appending them to relWork cache
        # what to do if nothing is found?

    def item_exists(self, *, mtype: str, ID: int) -> bool:
        """
        Just providing a more direct access to the cache.
        """
        return self.cache.item_exists(mtype=mtype, ID=ID)

    def item_is_online(self, *, mtype: str, ID: int) -> bool:
        """
        Report if, according to info in cache, the item has SMB-Freigabe.
        """
        if not self.item_exists(mtype=mtype, ID=ID):
            raise KeyError("ERROR: Item not in Cache")

        r = self.cache.xpath(
            f"""/m:application/m:modules/m:module[
                @name = '{mtype}']/m:moduleItem[
                @id = {str(ID)}]/m:repeatableGroup[
                @name = 'ObjPublicationGrp']/m:repeatableGroupItem[
                    m:vocabularyReference[@name='PublicationVoc']/m:vocabularyReferenceItem[@name='Ja'] 
                    and m:vocabularyReference[@name='TypeVoc']/m:vocabularyReferenceItem[@id = 2600647]
                ]"""
        )
        if len(r) > 0:
            return True
        else:
            return False

    def length(self) -> int:
        """
        Return the length of the cache (number of items in cache) as interger.
        """
        return len(self.cache)

    def load_cache_file(self) -> Path:
        """
        Load a cache file. If it doesn't exist, do nothing.
        The content of file is added to the existing in-memory cache.

        Returns the path used for the cache file.
        """
        path: Path = self.cache_path
        if path.exists():
            newM = Module(file=path)
            self.cache += newM
        return path

    def save(self) -> Path:
        """
        Save current in-memory cache with relWork information to disk. Supply a path
        if you want a non-default file path.

        Returns the path used for the cache file.
        """
        path: Path = self.cache_path
        self.cache.toFile(path=path)
        return path

    #
    # private
    #

    def _lido_to_ids(self, path: Path) -> set[tuple[str, int]]:
        """
        Given the path to lido file, we return a (distinct) set of items that
        are not yet in relWorks cache.

        Background: It is likely that one lido file refers to the same relWorks
        multiple times. Hence, we're weeding out these duplicates before do the
        lookup.
        """
        chunkET = etree.parse(str(path))

        relWorksL = chunkET.xpath(
            """/l:lidoWrap/l:lido/l:descriptiveMetadata/l:objectRelationWrap/
            l:relatedWorksWrap/l:relatedWorkSet/l:relatedWork/l:object/l:objectID""",
            namespaces=NSMAP,
        )

        id_cache = set()
        for ID_N in relWorksL:
            src = ID_N.xpath("@l:source", namespaces=NSMAP)[0]
            if src == "OBJ.ID":
                mtype = "Object"
            elif src == "LIT.ID":
                mtype = "Literature"
            else:
                raise ValueError(f"ERROR: Unknown type: {src}")

            id_int = int(ID_N.text)
            if not self.cache.item_exists(mtype=mtype, ID=id_int):
                id_cache.add((mtype, id_int))
            # else:
            #    print(f"item {mtype} {id_int} already in relWorks cache")
        return id_cache

    def _optimize_query(self, *, query: Search) -> Search:
        """
        Let's shrink (optimize) the xml. We only need a couple fields for the cache.
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
