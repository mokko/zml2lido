"""
    parse a LIDO file for linkResources
    check if link works and report
    perhaps correct linkResource
    
    <lido:linkResource lido:formatResource="image/jpeg">https://recherche.smb.museum/images/5403567_2500x2500.jpg</lido:linkResource>
    lidoWrap/lido/administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource
"""

from lxml import etree
import urllib.request

NSMAP = {"l" : "http://www.lido-schema.org"}


class LinkChecker: 
    def __init__ (self, *, input):
        tree = etree.parse(args.input)
        r = tree.xpath("//l:lidoWrap/l:lido/l:administrativeMetadata/l:resourceWrap/l:resourceSet/l:resourceRepresentation/l:linkResource/text()", namespaces=NSMAP)
        for link in r:
            print (link, end="")
            try:
                urllib.request.urlopen(link)
            except:
                print ("   NOT FOUND")
            else:
                print ("   EXISTS")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="LIDO linkChecker")
    parser.add_argument("-i", "--input", help="Path of lido input file", required=True)
    args = parser.parse_args()

    lc = LinkChecker(input=args.input)
