"""
Testing the saxonche to avoid java and subprocess
"""

import shutil
from zml2lido.lidoTool import LidoTool, xsl
from pathlib import Path


def test_saxon() -> None:
    lt = LidoTool(src="query516074-chunk1.xml")

    # print(f"{lt.src=}")
    assert str(lt.src == "query516074-chunk1.xml")

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
