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
        
"""
from pathlib import Path
import subprocess

#import shutil
saxLib = "C:\m3\SaxonHE10-5J\saxon-he-10.5.jar"
xsl = "C:\m3\zml2lido\zml2lido.xsl"

class LidoTool: 
    def __init__(self, *, input, output):
        print (f"input {input}")
        Input=Path(input)
        dir = Path(".").resolve().joinpath(output,Input.parent.name)
        print (f"output dir {dir}")
        if not dir.exists():
            print (f"Making new dir {dir}")
            dir.mkdir()
        outfile=dir.joinpath(Input.stem+".lido.xml")
        print (f"outfile:{outfile}")
        cmd = f"java -Xmx1200m -jar {saxLib} -s:{args.input} -xsl:{xsl} -o:{outfile}"

        print (f"cmd {cmd}")

        subprocess.run(
                cmd, check=True, stderr=subprocess.STDOUT
            )  # overwrites output file without saying anything
            
        
        
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Little LIDO toolchin")
    parser.add_argument("-i", "--input", help="job to run", required=True)
    parser.add_argument("-o", "--output", help="config file", default="sdata")
    args = parser.parse_args()

    m = LidoTool(input=args.input, output=args.output)

