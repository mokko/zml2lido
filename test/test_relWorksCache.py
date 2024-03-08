from pathlib import Path
import pytest
from zml2lido.relWorksCache import RelWorksCache


def test_init():
    rw = RelWorksCache()
    assert rw.maxSize == 20_000
    rw = RelWorksCache(maxSize=40_000)
    assert rw.maxSize == 40_000
    # print (f"{rw.maxSize=}")


def test_lookup_relWork():
    """
    We test lookup_relWork and save...
    """
    fn = Path("relWorks_cache.xml")
    if fn.exists():
        fn.unlink()
    rw = RelWorksCache()
    rw.lookup_relWork(mtype="Object", ID=2268694)
    rw.save(path=fn)
    assert 1 == len(rw.cache)
    rw.lookup_relWork(mtype="Object", ID=3486950)
    assert 2 == len(rw.cache)
    # print (f"{rw=}")


def test_load_cache_file():
    fn = Path("relWorks_cache.xml")
    if fn.exists():
        fn.unlink()
    rw = RelWorksCache()
    rw.lookup_relWork(mtype="Object", ID=2268694)
    rw.save()

    rw2 = RelWorksCache()
    rw2.load_cache_file()
    assert 1 == rw2.length()


def test_item_exists():
    rw = RelWorksCache()
    rw.load_cache_file()
    # rw.lookup_relWork(mtype="Object", ID=2268694)
    # rw.save()
    assert rw.item_exists(mtype="Object", ID=2268694)
    assert not rw.item_exists(mtype="Multimedia", ID=2268694)


def test_item_is_online():
    rw = RelWorksCache()
    rw.load_cache_file()
    rw.lookup_relWork(mtype="Object", ID=2390487)  # not online

    assert rw.item_exists(mtype="Object", ID=2268694)
    assert rw.item_is_online(mtype="Object", ID=2268694)
    with pytest.raises(KeyError):
        assert rw.item_is_online(mtype="Multimedia", ID=2268694)


def test_lido_to_ids():
    """
    Also tests 'lookup_from_lido_file'

    Runs fairly long, so we put it at the end.
    """
    rw = RelWorksCache()
    lido_fn = Path("group416397-chunk1.lido.xml")
    ids = rw._lido_to_ids(path=lido_fn)
    assert 171 == len(ids)
    rw.lookup_from_lido_file(path=lido_fn)
    ids2 = rw._lido_to_ids(path=lido_fn)
    assert 0 == len(ids2)
    assert 171 == rw.length()
    # print(f"{rw.length()}")
