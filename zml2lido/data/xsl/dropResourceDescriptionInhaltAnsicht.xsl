<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!--
	expects: LIDO
	outputs: LIDO
	
	filter out relatedWorks
	-->
	
	<xsl:template match="@*|node()">
		<xsl:copy>
		  <xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- 
		drop 
		Problem: relatedWorksWrap may well remain empty
	-->
	<xsl:template match="/lido:lidoWrap/lido:lido/lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet/lido:resourceDescription">
		<xsl:message>
			<xsl:text>dropping resourceDescription: </xsl:text>
			<xsl:value-of select="."/>
		</xsl:message>
	</xsl:template>
</xsl:stylesheet>

