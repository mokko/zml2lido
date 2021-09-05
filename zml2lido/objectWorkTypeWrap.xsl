<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="objectWorkTypeWrap">
        <lido:objectWorkTypeWrap>
			<lido:objectWorkType lido:type="Sachbegriff">
				<lido:conceptID lido:type="id">
					<xsl:value-of select="z:repeatableGroup[@name='ObjTechnicalTermGrp']/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermVoc']/z:vocabularyReferenceItem/@id"/>
				</lido:conceptID>
				<lido:term>
					<xsl:value-of select="z:repeatableGroup[@name='ObjTechnicalTermGrp']/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:term>
			</lido:objectWorkType>
        </lido:objectWorkTypeWrap>
	</xsl:template>

</xsl:stylesheet>