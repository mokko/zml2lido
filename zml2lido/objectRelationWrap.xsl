<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!--  
	objectRelationWrap(spec 1.0): Wrapper for infomation about related topics and works,
	collections, etc.
	
	Why subjectWrap is here, I dont understand, but who cares.
	-->

	<xsl:template name="objectRelationWrap">
		<lido:objectRelationWrap>
			<!-- subjectWrap todo -->
			<!-- relatedWorksWrap -->
			<lido:relatedWorksWrap>
				<xsl:apply-templates select="z:composite[@name='ObjObjectCre']/z:compositeItem"/>
			</lido:relatedWorksWrap>
		</lido:objectRelationWrap>
    </xsl:template>

	<xsl:template match="z:composite[@name='ObjObjectCre']/z:compositeItem">
			<xsl:apply-templates select="z:moduleReference[@name = 'ObjObjectARef']/z:moduleReferenceItem"/>
	</xsl:template>
   
    <xsl:template match="z:moduleReference[@name = 'ObjObjectARef']/z:moduleReferenceItem">
        <lido:relatedWorkSet>
            <lido:relatedWork>
                <lido:displayObject>
                    <xsl:value-of select="z:formattedValue"/>
                </lido:displayObject>
            </lido:relatedWork>
            <lido:relatedWorkRelType>
                <lido:term>
                    <xsl:value-of select="z:vocabularyReference[@name = 'TypeAVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
                </lido:term>
            </lido:relatedWorkRelType>
        </lido:relatedWorkSet>
    </xsl:template>
</xsl:stylesheet>