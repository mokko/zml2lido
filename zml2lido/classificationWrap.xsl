<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- SPEC
	1.0
		Wrapper for data classifying the object / work.
		Includes all classifying information about an object / work, such
		as: object / work type, style, genre, form, age, sex, and phase, or
		by how holding organization structures its collection (e.g. fine art,
		decorative art, prints and drawings, natural science, numismatics,
		or local history).
	1.1
		A wrapper for classification statements about the object/work in focus, including
		object/work type and classification.
	 -->

	<xsl:template name="classificationWrap">
        <lido:classificationWrap>
			<xsl:choose>
				<!-- specific to EM; EM-Sachbegriff Thesaurus -->
				<xsl:when test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem[@moduleItemId = '67678']">
					<xsl:apply-templates mode="classification" select="z:repeatableGroup[@name ='ObjTechnicalTermGrp']
						/z:repeatableGroupItem//z:vocabularyReference[@name='TechnicalTermEthnologicalVoc']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="classification" select="z:dataField[@name = 'ObjTechnicalTermClb']/z:value"/>
				</xsl:otherwise>
			</xsl:choose>
        </lido:classificationWrap>
	</xsl:template>

	<xsl:template mode="classification" match="z:dataField[@name = 'ObjTechnicalTermClb']/z:value">
		<lido:classification lido:type="Sachbegriff">
			<lido:term>
				<xsl:value-of select="."/>
			</lido:term>
		</lido:classification>
	</xsl:template>

	<xsl:template mode="classification" match="z:repeatableGroup[@name ='ObjTechnicalTermGrp']
		/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermEthnologicalVoc']">
		<lido:classification lido:type="EM Sachbegriff">
			<xsl:call-template name="conceptTerm"/>
		</lido:classification>
	</xsl:template>	

</xsl:stylesheet>