# zml2lido - Xslt that rewrites ZML to Lido

"zml" refers to Zetcom's "generic" xml format that comes out of MpRia's API.
* See: http://docs.zetcom.com/ws/ 
* For LIDO see http://www.lido-schema.org
* main xslt mapping is at zml2lido/data/xsl/zml2lido.xsl

## Requires
* lxml
* Saxon. We're now using saxonche from pypi. Install with
> pip install saxonche

The mapping is partly specific to the RIA installation of the SPK, but might 
inspire others.

Includes the following scripts
* lido
* lvalidate
* saxon

## Usage

> lido -j smb -i path/to/generic_xml # writes output to script_dir/sdata/20221023/label 

use -f to force overwrite existing files

## Common Jobs
job 'smb' does the following steps
1. convert to LIDO (lvl1)
2. filter out lido records that are not published
3. filter out relatedWorks tht are not pubished (except Literature)
4. validate LIDO
5. split

job 'dd' does the following
1. convert to LIDO (lvl1)
2. validate LIDO

## Common Errors
todo