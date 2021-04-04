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
            <xsl:apply-templates select="z:vocabularyReference[@name = 'ObjCategoryVoc']"/>
        </lido:objectWorkTypeWrap>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module/z:moduleItem/z:vocabularyReference[@name = 'ObjCategoryVoc']">
		<lido:objectClassificationWrap lido:type="Objekttyp">
			<!-- todo:sortorder; objekttyp can be only one -->
			<xsl:call-template name="conceptTerm"/>
		</lido:objectClassificationWrap>
	</xsl:template>	
</xsl:stylesheet>