"""
	Little script that converts native Zetcom xml to lido
	
    NEW
    This is a new version that does not require java subprocess anymore
    and uses saxon in c (saxonche) directory (installed with pip).

    This version also does no longer need to be executed from script 
    directory like C:/m3/zml2lido anymore.
    
    lido Command Line Tool
    You need to specify three parameters 
        -j/--job: which flavor (job) of the transformation you want to use 
        -i/--src: where the src xml file is
        -o/--output: will be used as output directory; in my case 
            C:/m3/zml2lido/sdata/{output}

        cd C:/m3/zml2lido 
        lido -j smb -i c:/m3/MpApi/sdata/3Wege/3Wege20210904.xml -o 3Wege
        # writes lido to file C:/m3/zml2lido/sdata/3Wege/20210904.lido.xml

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
import logging
import os
import re
from saxonche import PySaxonProcessor
from typing import Iterable
from zipfile import ZipFile
from zml2lido.linkChecker import LinkChecker

xslDir = Path(__file__).parent / "data/xsl"
lidoXSD = Path(__file__).parent / "data/xsd/lido-v1.0.xsd"

xsl = {
    "zml2lido": xslDir / "zml2lido.xsl",
    "Inhalt": xslDir / "dropResourceDescriptionInhaltAnsicht.xsl",  # filter
    "Literatur": xslDir / "dropRelatedWorksLiterature.xsl",  # filter
    "splitLido": xslDir / "splitLido.xsl",
    "ohneLit": xslDir / "ohneLit.xsl",
}


class LidoTool:
    def __init__(
        self,
        *,
        src: str,
        force: bool = False,
        validation: bool = False,
        chunks: bool = False,
    ) -> None:
        """
        src: lido file or first chunk
        force: overwrites files
        validation: validate lido files?
        chunks: expect consecutively numbered and zipped lido files as src
        """

        self.validation = validation
        self.force = force
        self.chunks = chunks
        self.script_dir = Path(__file__).parents[1]

        self.src = self._sanitize(src=src)
        self.outdir = self._prepareOutdir()
        self._initLog()

    #
    # Steps
    #

    def execute(self, job: str) -> None:
        if job == "dd":
            # debug. Only lvl1
            lido_fn = self.zml2lido(src=self.src)
        elif job == "ddd":
            # debug. Only lvl1
            lido_fn = self.zml2lido(src=self.src)
            self._valsplit(lido_fn)
        elif job == "ohneLit":
            # use different xslt for lvl1 conversion plus lvl2
            lido_fn = self.zml2lido(src=self.src, xslt="ohneLit")
            lvl2_fn = self.to_lvl2(src=lido_fn)
            self._valsplit(lvl2_fn)
        elif job == "mitLit":
            # regular xslt, lvl2
            lido_fn = self.zml2lido(src=self.src)
            lvl2_fn = self.to_lvl2(src=lido_fn)
            self._valsplit(lvl2_fn)
        else:
            raise SyntaxError("ERROR: Unknown job name!")

    def lfilter(self, *, split: bool = False, Type: str) -> None:
        if Type not in xsl:
            raise TypeError(f"Error: Unknown type '{Type}'")

        new_fn = self.src.stem + f"-no{Type}.xml"
        out_fn = self.outdir / new_fn

        self.saxon(src=self.src, xsl=xsl[Type], output=out_fn)

        if split:
            self.force = True
            self.splitLido(src=out_fn)

    def to_lvl2(self, *, src: str) -> Path:
        if self.chunks:
            for chunkFn in self.loopChunks(src=src):
                new_fn = self.to_lvl2Single(src=chunkFn)
            return self.firstChunkName(src=new_fn)
        else:
            return self.to_lvl2Single(src=src)

    def to_lvl2Single(self, *, src: str | Path) -> Path:
        """
        Using Python rewrite (fix) generic Zetcom xml, mostly working on links (urls)
        """
        out_fn = self._lvl2_path(src)
        # print(f"lvl2: {out_fn}")
        # try:  # only load the first time
        #    self.lc: LinkChecker
        # except:
        self.lc = LinkChecker(src=src, chunks=self.chunks)  # reads cache
        if not out_fn.exists() or self.force:
            # self.lc.relWorks_cache_single(fn=src)
            self.lc.rmUnpublishedRecords()  # remove unpublished records (not on SMB-Digital)
            self.lc.fixRelatedWorks()
            self.lc.save(out_fn)
        else:
            print(f"   lvl2 already exists: {out_fn}")
        return out_fn

    def splitLido(self, *, src: str | Path) -> str | Path:
        # print("SPLITLIDO enter")
        if self.chunks:
            self.force = True  # otherwise subsequent chunks are not written
            for chunkFn in self.loopChunks(src=src):
                self.splitLidoSingle(src=chunkFn)
        else:
            self.splitLidoSingle(src=src)
        return src  # dont act on split files

    def splitLidoSingle(self, *, src: str | Path) -> None:
        """
        Create individual files per lido record
        """
        # orig = Path.cwd()
        splitDir = self.outdir / "split"
        # existance of splitDir is a bad criterion, but cant think of a better one
        if not splitDir.exists() or self.force:  # self.force is True was problematic
            print("SPLITLIDO making")
            # os.chdir(self.script_dir)
            self.saxon(src=src, xsl=xsl["splitLido"], output="o.xml")
            # os.chdir(orig)
        else:
            print(f" SPLIT DIR exists already: {splitDir}")

    def splitSachbegriff(self, *, src: str) -> Path:
        print("SPLITSACHBEGRIFF")
        if self.chunks:
            for chunkFn in self.loopChunks(src=src):
                sachbegriffFn = self.splitSachbegriff(src=chunkFn)
            return self.firstChunkName(src=sachbegriffFn)
        else:
            return self.splitSachbegriffSingle(src=src)

    def splitSachbegriffSingle(self, *, src: str) -> Path:
        """
        Writes two files to output dir
        ohneSachbegriff.xml is meant for debugging.
        """
        orig = Path.cwd()
        # os.chdir(self.outdir)
        out = "mitSachbegriff.xml"
        if not Path(out).exists() or self.force is True:
            self.saxon(src=src, xsl=xsl["splitSachbegriff"], output=out)
        else:
            print(f"{out} exist already, no overwrite")
        # os.chdir(orig)
        return xslDir / out

    def validate(self, *, path: Path | None = None):
        """
        It's optionally possible to specify a path for a file that needs validatation. If
        path is None, the file that was specified during __init__ will be validated.

        If the method validate doesn't die, data validates.

        (Not tested recently for chunks...)
        """

        if path is None:
            to_val_fn = Path(self.src)
        else:
            to_val_fn = path

        print(f"VALIDATING LIDO FILE '{to_val_fn}'")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.loopChunks(src=to_val_fn):
                self.validateSingle(src=chunkFn)
        else:
            self.validateSingle(src=to_val_fn)

    def validateSingle(self, *, src: Path):
        if not hasattr(self, "schema"):
            print(f" loading schema {lidoXSD}")
            schemaDoc = etree.parse(lidoXSD)
            self.schema = etree.XMLSchema(schemaDoc)

        print(f" validating {src}")
        doc = etree.parse(str(src))
        self.schema.assert_(doc)  # raises error when not valid
        return src

    def zml2lido(self, *, src: str | Path | None = None, xslt="zml2lido") -> Path:
        if src is None:
            src = self.src
        # print(f"ZML2LIDO {xslt}")
        if self.chunks:
            print(" with chunks")
            for chunkFn in self.loopChunks(src=self.src):
                lidoFn = self.zml2lidoSingle(src=chunkFn, xslt=xslt)
            return self.firstChunkName(src=lidoFn)
        else:
            return self.zml2lidoSingle(src=src, xslt=xslt)

    def zml2lidoSingle(self, *, src: str | Path, xslt="zml2lido") -> Path:
        """
        Convert a single file from zml to lido using the specified xslt.
        src is a full path.
        """
        srcP = Path(src)
        lidoFn = self.outdir.joinpath(srcP.stem + ".lido.xml")
        print(f"zml2lidoSingle with {xsl[xslt]}")  # with file '{lidoFn}'

        if self.force is True or not lidoFn.exists():
            if srcP.suffix == ".zip":  # unzipping temp file
                print("   src is zipped")
                parent_dir = srcP.parent
                member = Path(srcP.name).with_suffix(".xml")
                temp_fn = parent_dir / member
                with ZipFile(srcP, "r") as zippy:
                    zippy.extract(str(member), path=parent_dir)
                new_src = temp_fn
            else:
                new_src = srcP

            self.saxon(src=new_src, xsl=xsl[xslt], output=lidoFn)

            if srcP.suffix == ".zip":
                temp_fn.unlink()
        else:
            print(f"exists {lidoFn}")
        return lidoFn

    #
    # more helpers
    #

    def loopChunks(self, *, src: str | Path) -> Iterable[str | Path]:
        """
        returns generator with path for existing files, counting up as long
        files exist. For this to work, filename has to include
            path/to/group1234-chunk1.xml

        This might belong in chunker,py to be reusable.
        """
        print(f"chunk src: {src}")
        root, no, tail = self._analyze_chunkFn(src=src)
        chunkFn = src
        while Path(chunkFn).exists():
            yield chunkFn
            # print(f"{chunkFn} exists")
            no += 1
            chunkFn = f"{root}-chunk{no}{tail}"

    def firstChunkName(self, *, src: str | Path):
        """
        returns the chunk with no. 1

        This might belong in chunker.py...

        Can we get the first file instead of forcing people to
        start with chunk1?
        List glob root* and take the first item?
        """
        root, no, tail = self._analyze_chunkFn(src=src)
        src = Path(src)
        parent = src.parent
        folder = {}
        for each in parent.iterdir():
            if str(each).startswith(root):
                root, no, tail = self._analyze_chunkFn(src=each)
                folder[no] = each
        no = min(folder.keys())
        firstFn = folder[no]
        # print(f"***firstChunkName {firstFn}")
        return firstFn

    def saxon(
        self, *, output: str | Path, xsl: str | Path, src: str | Path | None = None
    ) -> None:
        """
        New: src is optional (for the LidoTool's method).

        saxon could also be a function outside of this class.

        lc = LidoTool(src="ere.xml")
        lc.saxon(xsl="test.xsl", output="out.xml")
        lc.saxon(src="other.xml", xsl="test.xsl", output="out.xml")
        """
        if src is None:
            src = self.src

        if not Path(src).exists():
            raise SyntaxError(f"ERROR: src {src} does not exist!")

        if not Path(xsl).exists():
            raise SyntaxError("ERROR: xsl file does not exist!")

        # https://stackoverflow.com/questions/78468764
        xml_file_name = Path(src).absolute().as_uri()

        orig = Path.cwd()
        with PySaxonProcessor(license=False) as proc:
            xsltproc = proc.new_xslt30_processor()
            executable = xsltproc.compile_stylesheet(stylesheet_file=str(xsl))
            xml = proc.parse_xml(xml_file_name=xml_file_name)
            os.chdir(self.script_dir)  # so that saxon finds vocmap.xml
            result_tree = executable.apply_templates_returning_file(
                xdm_node=xml, output_file=str(output)
            )
            os.chdir(orig)
        # print(result_tree) # None

    #
    # private helper
    #

    def _analyze_chunkFn(self, *, src: str | Path) -> tuple[str, int, str]:
        """
        src could be Path or str.

        This might belong in chunker.py ...
        """
        # print(f"ENTER ANALYZE WITH {src}")
        partsL = str(src).split("-chunk")
        root = partsL[0]
        m = re.match(r"(\d+)[\.-]", partsL[1])
        if m is not None:
            no = int(m.group(1))
        tail = str(src).split("-chunk" + str(no))[1]
        # print(f"_ANALYZE '{root}' '{no}' '{tail}'")
        return root, no, tail

    def _initLog(self) -> None:
        logfile = self.outdir / "lidoTool.log"

        # let's append to the log file so we can aggregrate results from multiple runs
        logging.basicConfig(
            filename=logfile, filemode="a", encoding="utf-8", level=logging.INFO
        )

    def _lvl2_path(self, p: str | Path) -> Path:
        """
        Given a lvl1 lido path, determine the lvl2 path
        """
        p = Path(p)
        suffixes = "".join(p.suffixes)
        stem = str(p.name).split(".")[0]  # splits off multiple suffixes
        new_dir = p.parent  # / "lvl2"
        # new_dir.mkdir(exist_ok=True)
        new_p = new_dir.joinpath(stem + "-lvl2" + suffixes)
        return new_p

    def _prepareOutdir(self) -> Path:
        """
        Determining outdir based on self.src and its parent directories.
        We want to save outputs in {script_dir}/sdata.

        Tests write to zml2lido/sdata
        """
        sdataP = self.script_dir / "sdata"
        if re.match(r"\d\d\d\d\d\d", self.src.parent.name):
            outdir = sdataP / self.src.parents[1].name / self.src.parent.name
        elif self.src.parent.name == "sdata":
            # print("_outdir:Case2")
            outdir = sdataP
            # raise SyntaxError(
            #    """ERROR: Don't use an src file inside of sdata.
            #    Use a subdirectory instead!"""
            # )
        else:
            # should write in sdata/ccc for example, which may be pwd
            outdir = sdataP / self.src.parent.resolve().name
            print(f"Case3: {outdir=}")

        if not outdir.exists():
            print(f"Making new dir {outdir}")
            outdir.mkdir(parents=True, exist_ok=False)
        # print(f" outdir {outdir}")
        return outdir

    def _sanitize(self, *, src: str | Path) -> Path:
        """
        src could be Path or str.

        Some checks for convenience; mainly for our users, so they get more intelligable
        error messages.
        """
        # script_dir = Path(__file__).parents[1]
        # print(f"SCRIPT_DIR: {script_dir}")

        # Let's lift this requirement, which means that we have to generate proper
        # paths so that data is saved into sdata directory independent of pwd
        # we also have to provide the proper path for vocmap in saxon
        # if not Path.cwd().samefile(script_dir):
        #    raise SyntaxError(f"ERROR: Call me from directory '{script_dir}', please!")

        # check src
        if src is None:
            raise SyntaxError("ERROR: src can't be None!")
        src = Path(src)  # initial src file, e.g. 3Wege.zml.xml

        if src.is_dir():
            raise SyntaxError("ERROR: src is directory!")
        elif not src.exists():
            raise SyntaxError("ERROR: src does not exist!")

        return src

    def _valsplit(self, fn):
        if self.validation:
            self.validate(path=fn)
        self.splitLido(src=fn)
