"""
	Little script that converts native Zetcom xml to lido
	
    lido Command Line Tool
    Execute lido from the command line in the project dir. That is the 
    dir above sdata. In my case that is 
        C:\M3\zml2lido
    You need to specify three parameters 
        -j/--job: which flavor (job) of the transformation you want to use 
        -i/--input: where the input xml file is
        -o/--output: will be used as output directory; in my case 
            C:\m3\zml2lido\sdata\{output}

        cd C:\m3\zml2lido 
        lido -j smb -i c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml -o 3Wege
        # writes lido to file C:\m3\zml2lido\sdata\3Wege\20210904.lido.xml

	Flavors (aka jobs):
    FvH wants links in the Internet instead of image files, but we still give 
    images to the rst project. So we have different flavors or chains of steps 
    for these purposes. See jobs.py for details
    - smb: for FvH
    - dd: for debug
    - localLido: for rst
    
    In an old version it did also image processing, but that function is
    currently not used/tested. 
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
        return Input  # dont act on html

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
            return self.chunkNameFirst(Input=new_fn)
        else:
            return self.onlyPublishedSingle(Input=Input)

    def onlyPublishedSingle(self, *, Input):
        """
        filter out lido records that are not published at recherche.smb
        expects lido as input and outputs lido as well
        """
        Input = Path(Input)  # what a mess
        stem = str(Input).split(".")[0]
        ext = "".join(Input.suffixes)
        out = self.outdir.joinpath(stem + ".onlyPub" + ext)

        if not Path(out).exists() or self.force is True:
            self.saxon(Input=Input, xsl=xsl["onlyPublished"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        return out

    def urlLido(self, *, Input):
        # print("LINKCHECKER")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                new_fn = self.urlLidoSingle(Input=chunkFn)
            return self.chunkNameFirst(Input=new_fn)
        else:
            return self.urlLidoSingle(Input=Input)

    def urlLidoSingle(self, *, Input):
        """
        Using Python rewrite (fix) generic Zetcom xml, mostly workng on
        links (urls)
        """
        lc = LinkChecker(Input=Input)
        outFn = lc.out_fn
        if not Path(outFn).exists() or self.force == True:
            lc.rmUnpublishedRecords()  # remove unpublished records (not on SMB-Digital)
            lc.guess()  # rewrite filenames with http-links on SMB-Digital
            # lc.rmInternalLinks()  # remove resourceSets with internal links
            lc.fixRelatedWorks()
            lc.saveTree()
        else:
            print(f"   rewrite exists already: {outFn}, no overwrite")
        return outFn

    def splitSachbegriff(self, *, Input):
        print("SPLITSACHBEGRIFF")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                sachbegriffFn = self.splitSachbegriff(Input=chunkFn)
            return self.chunkNameFirst(Input=sachbegriffFn)
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
        return xslDir.joinpath(out)

    def pix(self, *, Input, output):
        """
        input is c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml
        read from C:\m3\MpApi\sdata\3Wege\pix_*
        write to C:\m3\zml2lido\sdata\3Wege\*
        resize so that biggest side is 1848px

        CAVEAT: it works on all pix from source dir; there are situations where
        records may have been filtered out, eg. from splitSachbegriff and pix
        may end up in target that are no longer included

        TODO: fix. Let's only work on pix that are referenced in a lido file
        """
        print("WORKING ON PIX")
        in_dir = Path(Input).parent
        # print (f"*input {in_dir}")
        for pic_fn in Path(in_dir).rglob(f"**/pix_*/*"):
            # print (f"{pic_fn}")
            self._resize(pic=pic_fn)

    def splitLido(self, *, Input):
        print("SPLITLIDO enter")
        if self.chunks:
            for chunkFn in self.chunkName(Input=Input):
                self.splitLidoSingle(Input=chunkFn)
        else:
            self.splitLidoSingle(Input=Input)
        return Input  # dont act on split files

    def splitLidoSingle(self, *, Input):
        """
        Create individual files per lido record
        """
        orig = os.getcwd()
        splitDir = self.outdir.joinpath("split")
        # existance of splitDir is a very bad criterion, but cant think of a better one
        if splitDir.exists or self.force is True:  # problematic
            print("SPLITLIDO making")
            os.chdir(self.outdir)
            self.saxon(Input=Input, xsl=xsl["splitLido"], output="o.xml")
            os.chdir(orig)
        else:
            print(f" SPLIT DIR exists already: {splitDir}")

    def validate(self, *, Input):
        print("VALIDATING LIDO")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.chunkName(Input=Input):
                self.validateSingle(Input=chunkFn)
        else:
            self.validateSingle(Input=Input)
        return Input  # validate does not write new files

    def validateSingle(self, *, Input):
        if not hasattr(self, "schema"):
            print(f" loading schema {lidoXSD}")
            schemaDoc = etree.parse(lidoXSD)
            self.schema = etree.XMLSchema(schemaDoc)

        print(f" validating {Input}")
        doc = etree.parse(str(Input))
        self.schema.assert_(doc)  # raises error when not valid
        return Input

    def zml2lido(self, *, Input):
        print("ZML2LIDO")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.chunkName(Input=self.Input):
                lidoFn = self.zml2lidoSingle(Input=chunkFn)
            return self.chunkNameFirst(Input=lidoFn)
        else:
            return self.zml2lidoSingle(Input=Input)

    def zml2lidoSingle(self, *, Input):
        inputP = Path(Input)
        lidoFn = self.outdir.joinpath(inputP.stem + ".lido.xml")
        # print (f"lido file:{lido_fn}")

        if not lidoFn.exists() or self.force is True:
            print("ZML2LIDO new")
            self.saxon(Input=inputP, xsl=xsl["zml2lido"], output=lidoFn)
        else:
            print("exists already, no overwrite")
        return lidoFn

    #
    # more helpers
    #

    def chunkNameFirst(self, *, Input):
        """
        returns the chunk with no. 1
        """
        root, no, tail = self._analyze_chunkFn(Input=Input)
        firstFn = f"{root}-chunk1{tail}"
        # print(f"going in {Input}")
        print(f"firstFn {firstFn}")
        return firstFn

    def _analyze_chunkFn(self, *, Input):
        print(f"ENTER ANALYZE WITH {Input}")
        partsL = str(Input).split("-chunk")
        root = partsL[0]
        m = re.match("(\d+)[\.-]", partsL[1])
        no = int(m.group(1))
        tail = str(Input).split("-chunk" + str(no))[1]
        print(f"_ANALYZE '{root}' '{no}' '{tail}'")
        return root, no, tail

    def chunkName(self, *, Input):
        """
        returns generator with path for existing files, counting up as long
        files are existing. For this to work, filename has to include
            path/to/group1234-chunk1.xml
        """
        print(f"chunk input: {Input}")
        root, no, tail = self._analyze_chunkFn(Input=Input)
        chunkFn = Input
        while Path(chunkFn).exists():
            yield chunkFn
            # print(f"{chunkFn} exists")
            no += 1
            chunkFn = f"{root}-chunk{no}{tail}"

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
        print(cmd)

        subprocess.run(
            cmd, check=True  # , stderr=subprocess.STDOUT
        )  # overwrites output file without saying anything
