"""
	Little script that converts input file to lido
	We can also add image stuff and other steps from the toolchain.

	source comes from c:\m3\MpApi\sdata\<something>
	I can specify the path from the command line and expect relative files from there
		
	Where do we write the output: C:\m3\zml2lido\sdata\<something>
	I could bake that path in or specify it on the commandline. The latter is more explicit.
	
    cd C:\m3\zml2lido
    lido.py -i c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml -o sdata 
    # writes lido to file C:\m3\zml2lido\sdata\3Wege\20210904.lido.xml
    # writes images to dir C:\m3\zml2lido\sdata\3Wege

    TODO: Check whether we only get freigegebene multimedia from MpApi.

    We do a sloppy update, i.e. if attachments have been deleted in RIA, they will
    remain in the lido sphere. So it wouldn't hurt to check smbfreigabe on asset level again
    during conversion to lido although we only downloaded smbfreigegebene assets in the 
    first place.

   
"""
from lxml import etree
import logging
from pathlib import Path
import os
from PIL import Image, ImageFile
import shutil
import subprocess
ImageFile.LOAD_TRUNCATED_IMAGES = True

#import shutil
saxLib = r"C:\m3\SaxonHE10-5J\saxon-he-10.5.jar"
lidoXSD = r"C:\m3\zml2lido\xsd\lido-v1.0.xsd"
zml2lidoXSL = r"C:\m3\zml2lido\zml2lido.xsl"
lido2htmlXSL = r"C:\m3\zml2lido\xsl\lido2html.xsl"
splitLidoXSL = r"C:\m3\zml2lido\xsl\splitLido.xsl"

class LidoTool: 
    def __init__(self, *, input, output, force):
        logfile = Path(output).joinpath("pix.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.INFO
        )
        self.force = force

        print (f" input {input}")
        Input = Path(input)
        self.dir = Path(".").resolve().joinpath(output,Input.parent.name)
        print (f" output dir {self.dir}")
        if not self.dir.exists():
            print (f"Making new dir {dir}")
            self.dir.mkdir()

        lido_fn = self.zml2lido(input=input, output=output)
        self.validate(input=lido_fn)
        self.splitLido(input=lido_fn)
        self.pix(input=input, output=output) # transforms attachments
        self.lido2html(input=lido_fn)
    
    def _copy (self, *, pic, out):
        if not Path(out).exists:
            print (f"*copying {pic} -> {out}")
            shutil.copyfile(pic, out)

    def lido2html (self,*, input):
        """Only runs if html dir doesn't exist."""

        orig = os.getcwd()
        os.chdir(self.dir)
        hdir = Path("html")
        #if not any(os.scandir(str(hdir))):        
        if not hdir.exists():
            print ("LIDO2HTML making")
            hdir.mkdir()
            os.chdir(str(hdir)) 
            self._saxon(input=input, xsl=lido2htmlXSL, output="o.xml")
        else:
            print ("LIDO2HTML exists already")
        os.chdir(orig)

    def pix (self, *, input, output):
        """
            input is c:\m3\MpApi\sdata\3Wege\3Wege20210904.xml
            read from C:\m3\MpApi\sdata\3Wege\pix_*
            write to C:\m3\zml2lido\sdata\3Wege\*
            resize so that biggest side is 1848px
        """    
        print ("WORKING ON PIX")
        in_dir = Path(input).parent
        #print (f"*input {in_dir}")   
        for pic_fn in Path(in_dir).rglob(f"**/pix_*/*"):
            #print (f"{pic_fn}")
            self._resize(pic=pic_fn)

    def _saxon (self, *, input, output, xsl):
        cmd = f"java -Xmx1200m -jar {saxLib} -s:{input} -xsl:{xsl} -o:{output}"
        print (f" cmd {cmd}")

        subprocess.run(
                cmd, check=True, stderr=subprocess.STDOUT
            )  # overwrites output file without saying anything

    def splitLido (self, *, input):
        orig = os.getcwd()
        if not self.dir.joinpath("split").exists():
            print ("SPLITLIDO making")
            os.chdir(self.dir)
            self._saxon(input=input, xsl=splitLidoXSL, output="o.xml")
            os.chdir(orig)
        else:
            print ("SPLITLIDO exists already")

    def _resize (self,*, pic):
        out_fn = self.dir.joinpath(pic.name)
        if pic.suffix != ".mp3" and pic.suffix != ".pdf": #pil croaks over mp3
            im = Image.open(pic)
            if not out_fn.exists():
                print(f"{pic} -> {out_fn}")
                width, height = im.size
                if width > 1848 or height > 1848:
                    logging.info(f"{pic} exceeds size: {width} x {height}")
                    if width > height:
                        factor = 1848/width
                    else: # height > width or both equal
                        factor = 1848/height
                    new_size = (int(width*factor), int(height*factor))
                    print (f"*resizing {factor} {new_size}")
                    im = im.convert("RGB")    
                    out = im.resize(new_size, Image.LANCZOS)
                    out.save(out_fn)
                else:
                    self._copy(pic=pic,out=out_fn)
        else:
            self._copy(pic=pic,out=out_fn)

    def validate (self,*, input):
        print ("VALIDATING LIDO")
        print(f" looking for xsd at {lidoXSD} to validate {input}")
        schema_doc = etree.parse(lidoXSD)
        schema = etree.XMLSchema(schema_doc)
        doc = etree.parse(str(input))
        schema.assert_(doc)
        print(" validates ok")


    def zml2lido(self,*, input, output):
        Input = Path(input)
        lido_fn = self.dir.joinpath(Input.stem+".lido.xml")
        #print (f"lido file:{lido_fn}")
 
        if not lido_fn.exists() or self.force is True:
            print ("ZML2LIDO new")
            self._saxon(input=input, xsl=zml2lidoXSL, output=lido_fn)
        else:
            print ("ZML2LIDO exists already")

        return lido_fn
    
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Little LIDO toolchin")
    parser.add_argument("-i", "--input", help="zml input file", required=True)
    parser.add_argument("-o", "--output", help="output directory, defaults to sdata", default="sdata")
    parser.add_argument("-f", "--force", help="force overwrite existing lido", action='store_true')
    args = parser.parse_args()

    m = LidoTool(input=args.input, output=args.output, force=args.force)

