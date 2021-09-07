<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="lido">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- ROOT -->
    <xsl:template match="/">
        <xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
    </xsl:template>

	<xsl:template match="/lido:lidoWrap/lido:lido">
		<xsl:variable name="file" select="concat('split/',normalize-space(lido:lidoRecID),'.lido.xml')"/>
        <xsl:message>
			<xsl:value-of select="$file"/>
		</xsl:message>
        <xsl:result-document href="{$file}" method="xml" encoding="UTF-8">
			<lido:lidoWrap 	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
					<xsl:copy-of select="."/>
			</lido:lidoWrap>
		</xsl:result-document>
	</xsl:template>

</xsl:stylesheet>

