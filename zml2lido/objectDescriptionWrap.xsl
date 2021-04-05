<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="objectDescriptionWrap">
		<lido:objectDescriptionWrap>
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjTextGrp']/z:repeatableGroupItem"/>
		</lido:objectDescriptionWrap>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjTextGrp']/z:repeatableGroupItem">
		<lido:objectDescriptionSet>
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:attribute name="lido:encodinganalog">
					<xsl:value-of select="z:vocabularyReference/z:vocabularyReferenceItem/@name"/>
				</xsl:attribute> 
				<xsl:value-of select="z:dataField[@name='TextClb']"/>
			</lido:descriptiveNoteValue>
		</lido:objectDescriptionSet>
	</xsl:template>
   
</xsl:stylesheet>