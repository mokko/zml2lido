from pathlib import Path
from zml2lido.relWorksCache import RelWorksCache


def test_init():
    rw = RelWorksCache()
    assert rw.maxSize == 20_000
    rw = RelWorksCache(maxSize=40_000)
    assert rw.maxSize == 40_000
    # print (f"{rw.maxSize=}")


def test_add_relWork():
    """
    We test add_relWork and save...
    """
    fn = Path("relWorks_cache.xml")
    if fn.exists():
        fn.unlink()
    rw = RelWorksCache()
    rw.add_relWork(mtype="Object", ID=2268694)
    rw.save(path=fn)
    assert 1 == len(rw.cache)
    rw.add_relWork(mtype="Object", ID=3486950)
    assert 2 == len(rw.cache)
    # print (f"{rw=}")


def test_load_cache_file():
    fn = Path("relWorks_cache.xml")
    if fn.exists():
        fn.unlink()
    rw = RelWorksCache()
    rw.add_relWork(mtype="Object", ID=2268694)
    rw.save(path=fn)

    rw2 = RelWorksCache()
    rw2.load_cache_file(path=fn)
    assert 1 == rw2.length()


def test_lido_to_ids():
    """
    Also tests 'add_from_lido_file'
    """
    rw = RelWorksCache()
    lido_fn = Path("group416397-chunk1.lido.xml")
    ids = rw._lido_to_ids(path=lido_fn)
    assert 171 == len(ids)
    rw.add_from_lido_file(path=lido_fn)
    ids2 = rw._lido_to_ids(path=lido_fn)
    assert 0 == len(ids2)
    assert 171 == rw.length()
    print(f"{rw.length()}")
