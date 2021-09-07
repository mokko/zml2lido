<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="lido">

    <xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- ROOT -->
    <xsl:template match="/">
        <xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
    </xsl:template>

	<xsl:teamplate match="/lido:lidoWrap/lido:lido">
		<xsl:variable name="file" select="concat(normalize-space(lido:lidoRecID),'.lido.xml')"/>
        <xsl:message>
			<xsl:value-of select="$file"/>
		</xsl:message>
        <xsl:result-document href="{$file}" method="html" encoding="UTF-8">
			<xsl:copy-of select="n:npx/n:multimediaobjekt[n:verknüpftesObjekt = $nzIds]"/>
		</xsl:result-document>
	</xsl:teamplate>

</xsl:stylesheet>

