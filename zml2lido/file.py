"""
WORK IN PROGRESS - File helpers for zml2lido

We're currently only zipping zml files, not lido files automatically

unpacked_path = unzip(Path("group1234-chunk1.zip")

for chunk in per_chunk(chunk_path):
        do_something_with(chunk)

"""

from zipfile import ZipFile
from pathlib import Path
import re


def per_chunk(path: Path):
    """
    Loop through chunks easily. Not yet used in production.
    """
    path2 = path
    while path2.exists():
        yield path2
        stem = str(path2).split(".lido.xml")[0]
        m = re.search(r"-chunk(\d+)$", stem)
        if m:
            no = int(m.group(1))
            new_no = no + 1
            head = re.sub(r"\d+$", "", stem)
            path2 = Path(f"{head}{new_no}.lido.xml")
        else:
            raise Exception("Not chunkable")


def unzip(path: Path):
    parent_dir = path.parent
    member = Path(path.name).with_suffix(".xml")
    temp_fn = parent_dir / member
    with ZipFile(path, "r") as zippy:
        zippy.extract(str(member), path=parent_dir)
    return temp_fn
