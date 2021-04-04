<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- den Fall, das kein Titel vorhanden ist, behandeln wir später -->
	<xsl:template name="titleWrap">
        <lido:titleWrap>
        	<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectTitleGrp']/z:repeatableGroupItem"/>
		</lido:titleWrap>
    </xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem/z:repeatableGroup[@name='ObjObjectTitleGrp']/z:repeatableGroupItem">
		<lido:titleSet>
			<xsl:attribute name="type">
				<xsl:value-of select="z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/@name"/>
			</xsl:attribute>
			<lido:appellationValue sort="1">
				<xsl:value-of select="z:dataField[@name = 'TitleTxt']"/>
			</lido:appellationValue>
		</lido:titleSet>
	</xsl:template>
</xsl:stylesheet>