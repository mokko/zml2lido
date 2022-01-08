"""
	Little script that converts input file to lido
	We can also add image stuff and other steps from the toolchain.

	source comes from c:\m3\MpApi\sdata\<something>
	I can specify the path from the command line and expect relative files from there
		
	Where do we write the output: C:\m3\zml2lido\sdata\<something>
	I could bake that path in or specify it on the commandline. The latter is more explicit.
	
    cd C:\m3\zml2lido # needed for vocmap.xml!
    lido.py -i c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml -o sdata 
    # writes lido to file C:\m3\zml2lido\sdata\3Wege\20210904.lido.xml
    # writes images to dir C:\m3\zml2lido\sdata\3Wege

    TODO: Check whether we only get freigegebene multimedia from MpApi.

    We do a sloppy update, i.e. if attachments have been deleted in RIA, they will
    remain in the lido sphere. So it wouldn't hurt to check smbfreigabe on asset level again
    during conversion to lido although we only downloaded smbfreigegebene assets in the 
    first place.

    Changes
    1/6/22   transition to flit packaging
    10/28/21 move installation specific config to a separate file in sdata
    10/26/21 outdir simplified; it's always relative to pwd now. One  command line param less.
    10/21/21 new output dir
    10/20/21 only checkLinks if output file doesn't exist yet (as usual) 
    10/20/21 change java max memory
    10/20/21 zml2lido: usual additions to objectMeasurements
    9/25/21 introduce different chains: local and for SMB-Digital
    9/24/21 linkchecker guesses URL for image on recherche.smb 
    9/11/21 -f force should overwrite existing data in all steps, not just in zml2lido
    9/11/21 implement simple filter that filters out zml records of type object that have no sachbegriff
"""

from lxml import etree
from pathlib import Path
from PIL import Image, ImageFile
import logging
import os
import re
import shutil
import subprocess
import sys
from zml2lido.linkChecker import LinkChecker
from zml2lido.jobs import Jobs

ImageFile.LOAD_TRUNCATED_IMAGES = True
conf_fn = Path(__file__).parent.parent.joinpath("sdata", "lido_conf.py")
xslDir = Path(__file__).parent.joinpath("data/xsl")

with open(conf_fn) as f:
    exec(f.read())  # saxLib, lidoXSD

xsl = {
    "zml2lido": xslDir.joinpath("zml2lido.xsl"),
    "lido2html": xslDir.joinpath("lido2html.xsl"),
    "onlyPublished": xslDir.joinpath("filterPublished.xsl"),
    "splitLido": xslDir.joinpath("splitLido.xsl"),
    "splitSachbegriff": xslDir.joinpath("splitNoSachbegriff.xsl"),
}


class LidoTool(Jobs):
    def __init__(self, *, force=False, validation=False, Input=None, chunks=False):
        self.validation = validation
        self.force = force
        self.chunks = chunks
        if Input is not None:
            self.Input = Path(Input)  # initial input file, e.g. 3Wege.zml.xml
            if re.match("\d\d\d\d\d\d", self.Input.parent.name):
                self.outdir = (
                    Path("sdata")
                    .resolve()
                    .joinpath(self.Input.parent.parent.name, self.Input.parent.name)
                )
            else:
                self.outdir = Path("sdata").resolve().joinpath(self.Input.parent.name)

            # alternatively, we could make a new dir based on the input
            # C:\m3\MpApi\sdata\3Wege\3Wege20211019.xml
            # 3Wege -> sdata\3Wege
            if not self.outdir.exists():
                print(f"Making new dir {self.outdir}")
                self.outdir.mkdir(parents=True, exist_ok=False)
            print(f" outdir {self.outdir}")
            logfile = self.outdir.joinpath("lidoTool.log")
            # let's append to the log file so we can aggregrate results from multiple runs
            logging.basicConfig(
                filename=logfile, filemode="a", encoding="utf-8", level=logging.INFO
            )

    #
    # Steps
    #

    def lido2html(self, *, Input):
        print("LIDO2HTML")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.lido2htmlSingle(Input=chunkFn)
        else:
            self.lido2htmlSingle(Input=Input)

    def lido2htmlSingle(self, *, Input):
        """Only runs if html dir doesn't exist."""
        orig = os.getcwd()
        os.chdir(self.outdir)
        hdir = Path("html")
        # if not any(os.scandir(str(hdir))):
        if not hdir.exists() or self.force is True:
            print("making LIDO2HTML")
            hdir.mkdir(exist_ok=True)
            os.chdir(str(hdir))
            self.saxon(Input=Input, xsl=xsl["lido2html"], output="o.xml")
        else:
            print("LIDO2HTML exists already")
        os.chdir(orig)

    def onlyPublished(self, *, Input):
        print(f"ONLYPUBLISHED")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.onlyPublishedSingle(Input=chunkFn)
            return new_fn  # return last only
        else:
            return self.onlyPublishedSingle(Input=Input)

    def onlyPublishedSingle(self, *, Input):
        """
        filter out lido records that are not published at recherche.smb
        expects lido as input and outputs lido as well
        """
        stem = str(Input).split(".")[0]
        ext = "".join(Input.suffixes)
        out = self.outdir.joinpath(stem + ".onlyPub" + ext)

        if not Path(out).exists() or self.force is True:
            self.saxon(Input=Input, xsl=xsl["onlyPublished"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        return out

    def urlLido(self, *, Input):
        print("LINKCHECKER")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.urlLidoSingle(Input=chunkFn)
            return new_fn  # return last
        else:
            return self.urlLidoSingle(Input=Input)

    def urlLidoSingle(self, *, Input):
        lc = LinkChecker(Input=Input)
        out_fn = lc.out_fn
        if not Path(lc.out_fn).exists() or self.force == True:
            lc.rmUnpublishedRecords()  # remove records that are not published on SMB-Digital
            lc.guess()  # rewrite filenames with http-links on SMB-Digital
            lc.rmInternalLinks()  # remove resourceSets with internal links
            lc.saveTree()
        else:
            print(f"   rewrite exists already: {out_fn}, no overwrite")
        return out_fn

    def splitSachbegriff(self, *, Input):
        print("SPLITSACHBEGRIFF")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.splitSachbegriff(Input=chunkFn)
            return new_fn  # only last
        else:
            return self.splitSachbegriffSingle(Input=Input)

    def splitSachbegriffSingle(self, *, Input):
        """
        Writes two files to output dir
        ohneSachbegriff.xml is meant for debug purposes.
        """
        orig = os.getcwd()
        os.chdir(self.outdir)
        out = "mitSachbegriff.xml"
        if not Path(out).exists() or self.force is True:
            self.saxon(Input=Input, xsl=xsl["splitSachbegriff"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        os.chdir(orig)
        return self.dir.joinpath(out)

    def pix(self, *, Input, output):
        """
        input is c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml
        read from C:\m3\MpApi\sdata\3Wege\pix_*
        write to C:\m3\zml2lido\sdata\3Wege\*
        resize so that biggest side is 1848px

        CAVEAT: it works on all pix from source dir; there are situations where
        records may have been filtered out, eg. from splitSachbegriff and pix
        may end up in target that are no longer included

        TODO: fix
        """
        print("WORKING ON PIX")
        in_dir = Path(Input).parent
        # print (f"*input {in_dir}")
        for pic_fn in Path(in_dir).rglob(f"**/pix_*/*"):
            # print (f"{pic_fn}")
            self._resize(pic=pic_fn)

    def splitLido(self, *, Input):
        print("SPLITLIDO")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.splitLidoSingle(Input=chunkFn)
        else:
            return self.splitLidoSingle(Input=Input)

    def splitLidoSingle(self, *, Input):
        """
        Create invidiual files per lido record
        """
        orig = os.getcwd()
        if not self.outdir.joinpath("split").exists() or self.force is True:
            print("SPLITLIDO making")
            os.chdir(self.outdir)
            self.saxon(Input=Input, xsl=xsl["splitLido"], output="o.xml")
            os.chdir(orig)
        else:
            print("SPLITLIDO exists already")
            print("SPLITLIDO exists already")

    def validate(self, *, Input):
        print("VALIDATING LIDO")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.validateSingle(Input=chunkFn)
            return new_fn
        else:
            return self.validateSingle(Input=Input)

    def validateSingle(self, *, Input):
        print(f" loading schema {lidoXSD}")
        schema_doc = etree.parse(lidoXSD)
        print(f" validating {Input}")
        schema = etree.XMLSchema(schema_doc)
        doc = etree.parse(str(Input))
        schema.assert_(doc)  # raises error when not valid
        if schema.validate(doc):
            print(" validates ok")
        else:
            print(" does NOT validate")

    def zml2lido(self, *, Input):
        print("ZML2LIDO")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.chunkName(Input=self.Input):
                new_fn = self.zml2lidoSingle(Input=chunkFn)
            return new_fn  # only the last one returns
        else:
            return self.zml2lidoSingle(Input=Input)

    def zml2lidoSingle(self, *, Input):
        Input = Path(Input)
        lido_fn = self.outdir.joinpath(Input.stem + ".lido.xml")
        # print (f"lido file:{lido_fn}")

        if not lido_fn.exists() or self.force is True:
            print("ZML2LIDO new")
            self.saxon(Input=Input, xsl=xsl["zml2lido"], output=lido_fn)
        else:
            print("exists already, no overwrite")

        return lido_fn

    #
    # more private
    #

    def chunkName(self, *, Input):
        print(f"chunk input: {Input}")
        m = re.match(".*(\d+)\.xml$", str(Input))  # -chunk(\d+)\.xml$
        no = int(m.group(1))
        root = str(Input).split("-chunk")[0]
        chunkFn = Input
        while Path(chunkFn).exists():
            print(f"{chunkFn} exists")
            no += 1
            chunkFn = f"{root}-chunk{no}.xml"
            yield chunkFn

    def _copy(self, *, pic, out):
        if not Path(out).exists:
            print(f"*copying {pic} -> {out}")
            shutil.copyfile(pic, out)

    def _resize(self, *, pic):
        out_fn = self.dir.joinpath(pic.name)
        if pic.suffix != ".mp3" and pic.suffix != ".pdf":  # pil croaks over mp3
            im = Image.open(pic)
            if not out_fn.exists():
                print(f"{pic} -> {out_fn}")
                width, height = im.size
                if width > 1848 or height > 1848:
                    logging.info(f"{pic} exceeds size: {width} x {height}")
                    if width > height:
                        factor = 1848 / width
                    else:  # height > width or both equal
                        factor = 1848 / height
                    new_size = (int(width * factor), int(height * factor))
                    print(f"*resizing {factor} {new_size}")
                    im = im.convert("RGB")
                    out = im.resize(new_size, Image.LANCZOS)
                    out.save(out_fn)
                else:
                    self._copy(pic=pic, out=out_fn)
        else:
            self._copy(pic=pic, out=out_fn)

    def saxon(self, *, Input, output, xsl):
        cmd = f"java -Xmx1450m -jar {saxLib} -s:{Input} -xsl:{xsl} -o:{output}"
        print(f" cmd {cmd}")

        subprocess.run(
            cmd, check=True, stderr=subprocess.STDOUT
        )  # overwrites output file without saying anything
