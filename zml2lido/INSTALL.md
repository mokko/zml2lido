# INSTALL

## clone the repo
> git clone https://github.com/mokko/zml2lido.git
> cd zml2lido
> pip install .

## use flit alternatively
> flit install

## another alternative: editable install
> pip install -e .

# Scripts
zml2lio installs three scripts
- lido 
- saxon
- lvalidate

# Saxon
> saxon -h : help
> saxon -s C:\m3\MpApi\sdata\FvH\FvH\20220116\ISL3Wege-join-group121396.xml -x zml2lido\data\xsl\zml2lido.xsl -o o.xml
> lvalidate -i o.xml

> cd zml2lido
> lido -j smb -i path/to/source.xml

# CONFIGURATION

1. Currently, zml2lido needs a configuration file that lives inside the zml2lido 
installation directory:
	zml2lido/sdata/lido_conf.py

2. LinkChecker.py expects a sdata/credentials.py file relative to current working 
directory.
