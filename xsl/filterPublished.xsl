<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!--
	Filter out records that have not been published at SMB-Digital = recherche.smb.museum 
	(i.e. objects without objectPublishedID)
	Input: LIDO document
	Output: LIDO document
	-->
	
	<xsl:template match="/">
		<lido:lidoWrap>
			<xsl:copy-of select="/lido:lidoWrap/lido:lido[lido:objectPublishedID]"/>
		</lido:lidoWrap>
	</xsl:template>
</xsl:stylesheet>
