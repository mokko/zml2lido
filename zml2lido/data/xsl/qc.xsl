<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd"
	exclude-result-prefixes="z func">

	<!--
	We want a quality control tool that reports problems in LIDO. Should we do this in XSLT or in Python?
	In XSLT we would input xslt and output messages I guess.
	-->


	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<lido:lidoWrap 	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem" />
		</lido:lidoWrap>
	</xsl:template>

	
</xsl:stylesheet>