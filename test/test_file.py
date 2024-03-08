from pathlib import Path
from zml2lido.file import per_chunk


def test_per_chunk():
    p = Path(r"C:\m3\zml2lido\sdata\GG\20240307\query516069-chunk1.lido.xml")
    if not p.exists():
        raise FileNotFoundError("p not found!")
    assert 2 == len(list(per_chunk(p)))
