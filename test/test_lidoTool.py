"""
Testing the saxonche to avoid java and subprocess
"""

# import shutil
from zml2lido.lidoTool import LidoTool, xsl
from pathlib import Path


def test_firstChunkName() -> None:
    lt = LidoTool(src="group416397-chunk1.lido.xml")
    p = Path("query767070-chunk1.lido.xml")
    first_chunk = lt.firstChunkName(src=p)
    assert str(first_chunk) == "query767070-chunk1.lido.xml"

    p = Path("query767070-chunk10.lido.xml")
    first_chunk = lt.firstChunkName(src=p)
    assert str(first_chunk) == "query767070-chunk1.lido.xml"

    p = Path("query767070-chunk10.lvl2.lido.xml")
    first_chunk = lt.firstChunkName(src=p)
    assert str(first_chunk) == "query767070-chunk1.lido.xml"


def test_saxon() -> None:
    lt = LidoTool(src="group416397-chunk1.lido.xml")

    # print(f"{lt.src=}")
    assert str(lt.src == "group416397-chunk1.lido.xml")

    # print(f"{lt.outdir=}")
    script_dir = Path(__file__).parents[1]
    # hack to get vocmap in current path
    # currently requires vocmap.xml in current directory#
    # we want a relative path in xslt that is independent
    # let's overwrite depedent file every time
    # alternatively: we could cd to vocmap.xml's directory and then cd back
    assert str(lt.outdir == script_dir)

    # print(xsl["zml2lido"])
    lt.saxon(src=lt.src, xsl=xsl["zml2lido"], output="test.lido.xml")


def test_saxon_umlaut() -> None:
    lt = LidoTool(src="ä.xml")
    assert str(lt.src == "ä.xml")
    lido_fn = lt.zml2lido()
    print(f"{lido_fn=}")
