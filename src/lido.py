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

ImageFile.LOAD_TRUNCATED_IMAGES = True
srcDir = Path(__file__).parent
conf_fn = Path(__file__).parent.parent.joinpath("sdata", "lido_conf.py")
xslDir = Path(__file__).parent.parent.joinpath("xsl")

with open(conf_fn) as f:
    exec(f.read())  # saxLib, lidoXSD

from LinkChecker import LinkChecker

xsl = {
    "zml2lido": xslDir.joinpath("zml2lido.xsl"),
    "lido2html": xslDir.joinpath("lido2html.xsl"),
    "onlyPublished": xslDir.joinpath("filterPublished.xsl"),
    "splitLido": xslDir.joinpath("splitLido.xsl"),
    "splitSachbegriff": xslDir.joinpath("splitNoSachbegriff.xsl"),
}


class LidoTool:
    def __init__(self, *, input, force, validation):
        self.validation = validation
        self.force = force
        self.input = Path(input)  # initial input file, e.g. 3Wege.zml.xml
        if re.match("\d\d\d\d\d\d", self.input.parent.name):
            self.outdir = (
                Path("sdata")
                .resolve()
                .joinpath(self.input.parent.parent.name, self.input.parent.name)
            )
        else:
            self.outdir = Path("sdata").resolve().joinpath(self.input.parent.name)

        # alternatively, we could make a new dir based on the input
        # C:\m3\MpApi\sdata\3Wege\3Wege20211019.xml
        # 3Wege -> sdata\3Wege
        if not self.outdir.exists():
            print(f"Making new dir {self.outdir}")
            self.outdir.mkdir(parents=False, exist_ok=False)
        print(f" outdir {self.outdir}")
        logfile = self.outdir.joinpath("lidoTool.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.INFO
        )

    #
    # Jobs
    #

    def localLido(self):
        """
        localLido downloads images
        """
        mitSachbegriffZML = self.splitSachbegriff(
            input=self.input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(input=mitSachbegriffZML)
        if self.validation:
            self.validate(input=lido_fn)
        self.splitLido(input=lido_fn)  # individual records as files
        self.pix(input=self.input, output=self.output)  # transforms attachments
        self.lido2html(input=lido_fn)  # to make it easier to read lido

    def smbLido(self):
        """
        Make Lido that
        - image links: recherche.smb.
        - filter out records without sachbegriff
        - split
        - html
        """
        mitSachbegriffZML = self.splitSachbegriff(
            input=self.input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(input=mitSachbegriffZML)
        linklido_fn = self.urlLido(input=lido_fn)  # fix links and rm unpublished parts
        if self.validation:
            self.validate(input=linklido_fn)
        self.splitLido(input=linklido_fn)  # individual records as files
        self.lido2html(input=linklido_fn)  # to make it easier to read lido

    def smb(self):
        """
        Make Lido
        - filter out lido records that are not published
        - image links: recherche.smb
        - validate if -v on command line
        - split
        """
        lido_fn = self.zml2lido(input=self.input)
        onlyPublished = self.onlyPublished(input=lido_fn)
        linklido_fn = self.urlLido(
            input=onlyPublished
        )  # fix links and rm unpublished parts
        if self.validation:
            self.validate(input=linklido_fn)
        self.splitLido(input=linklido_fn)  # individual records as files
        # self.lido2html(input=linklido_fn)        # to make it easier to read lido

    #
    # Steps
    #

    def lido2html(self, *, input):
        """Only runs if html dir doesn't exist."""

        orig = os.getcwd()
        os.chdir(self.outdir)
        hdir = Path("html")
        # if not any(os.scandir(str(hdir))):
        if not hdir.exists() or self.force is True:
            print("making LIDO2HTML")
            hdir.mkdir(exist_ok=True)
            os.chdir(str(hdir))
            self._saxon(input=input, xsl=xsl["lido2html"], output="o.xml")
        else:
            print("LIDO2HTML exists already")
        os.chdir(orig)

    def onlyPublished(self, *, input):
        """
        filter out lido records that are not published at recherche.smb
        expects lido as input and outputs lido as well
        """
        stem = str(input).split(".")[0]
        ext = "".join(input.suffixes)
        out = self.outdir.joinpath(stem + ".onlyPub" + ext)

        if not Path(out).exists() or self.force is True:
            self._saxon(input=input, xsl=xsl["onlyPublished"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        return out

    def urlLido(self, *, input):
        lc = LinkChecker(input=input)
        out_fn = lc.out_fn
        if not Path(lc.out_fn).exists() or self.force == True:
            lc.rmUnpublishedRecords()  # remove records that are not published on SMB-Digital
            lc.guess()  # rewrite filenames with http-links on SMB-Digital
            lc.rmInternalLinks()  # remove resourceSets with internal links
            lc.saveTree()
        else:
            print(f"   rewrite exists already: {out_fn}, no overwrite")
        return out_fn

    def splitSachbegriff(self, *, input):
        """
        Writes two files to output dir
        ohneSachbegriff.xml is meant for debug purposes.
        """
        orig = os.getcwd()
        os.chdir(self.outdir)
        out = "mitSachbegriff.xml"
        if not Path(out).exists() or self.force is True:
            self._saxon(input=input, xsl=xsl["splitSachbegriff"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        os.chdir(orig)
        return self.dir.joinpath(out)

    def pix(self, *, input, output):
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
        in_dir = Path(input).parent
        # print (f"*input {in_dir}")
        for pic_fn in Path(in_dir).rglob(f"**/pix_*/*"):
            # print (f"{pic_fn}")
            self._resize(pic=pic_fn)

    def splitLido(self, *, input):
        """
        Create invidiual files per lido record
        """
        orig = os.getcwd()
        if not self.outdir.joinpath("split").exists() or self.force is True:
            print("SPLITLIDO making")
            os.chdir(self.outdir)
            self._saxon(input=input, xsl=xsl["splitLido"], output="o.xml")
            os.chdir(orig)
        else:
            print("SPLITLIDO exists already")
            print("SPLITLIDO exists already")

    def validate(self, *, input):
        print("VALIDATING LIDO")
        print(f" loading schema {lidoXSD}")
        schema_doc = etree.parse(lidoXSD)
        print(" validating...")
        schema = etree.XMLSchema(schema_doc)
        doc = etree.parse(str(input))
        schema.assert_(doc)  # raises error when not valid
        if schema.validate(doc):
            print(" validates ok")
        else:
            print(" does NOT validate")

    def zml2lido(self, *, input):
        Input = Path(input)
        lido_fn = self.outdir.joinpath(Input.stem + ".lido.xml")
        # print (f"lido file:{lido_fn}")

        if not lido_fn.exists() or self.force is True:
            print("ZML2LIDO new")
            self._saxon(input=input, xsl=xsl["zml2lido"], output=lido_fn)
        else:
            print("ZML2LIDO exists already")

        return lido_fn

    #
    # more private
    #

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

    def _saxon(self, *, input, output, xsl):
        cmd = f"java -Xmx1450m -jar {saxLib} -s:{input} -xsl:{xsl} -o:{output}"
        print(f" cmd {cmd}")

        subprocess.run(
            cmd, check=True, stderr=subprocess.STDOUT
        )  # overwrites output file without saying anything


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Little LIDO toolchin")
    parser.add_argument("-i", "--input", help="zml input file", required=True)
    parser.add_argument(
        "-j", "--job", help="pick job (localLido or smbLido)", required=True
    )
    parser.add_argument(
        "-f", "--force", help="force overwrite existing lido", action="store_true"
    )
    parser.add_argument("-v", "--validate", help="validate lido", action="store_true")
    args = parser.parse_args()

    if args.force:
        args.validate = True

    print(f"JOB: {args.job}")

    m = LidoTool(input=args.input, force=args.force, validation=args.validate)
    getattr(m, args.job)()
