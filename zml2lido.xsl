<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	exclude-result-prefixes="z" 
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

	<xsl:import href="zml2lido/objectWorkTypeWrap.xsl" />
	<xsl:import href="zml2lido/classificationWrap.xsl" />
	<xsl:import href="zml2lido/objectIdentificationWrap.xsl" />
	<xsl:import href="zml2lido/eventWrap.xsl" />
	<xsl:import href="zml2lido/objectRelationWrap.xsl" />
	<xsl:import href="zml2lido/rightsWorkWrap.xsl" />
	<xsl:import href="zml2lido/recordWrap.xsl" />
	<xsl:import href="zml2lido/resourceWrap.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<lido:lidoWrap 	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem" />
		</lido:lidoWrap>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem">
		<lido:lido>
			<lido:lidoRecID>
				<xsl:attribute name="lido:type">objId</xsl:attribute>
				<xsl:value-of select="@id" />
			</lido:lidoRecID>
			<xsl:call-template name="category" />

			<lido:descriptiveMetadata xml:lang="de">
				<xsl:call-template name="objectClassificationWrap" />
				<xsl:call-template name="objectIdentificationWrap" />
				<xsl:call-template name="eventWrap" />
				<xsl:call-template name="objectRelationWrap" />
			</lido:descriptiveMetadata>

			<lido:administrativeMetadata xml:lang="en">
				<xsl:call-template name="rightsWorkWrap" />
				<xsl:call-template name="recordWrap" />
				<xsl:call-template name="resourceWrap" />
			</lido:administrativeMetadata>
		</lido:lido>
	</xsl:template>

	<xsl:template name="category">
		<!-- Not sure how to map this, perhaps introduce a new Objekttyp upstream -->
		<lido:category>
			<lido:conceptID lido:type="URI">http://www.cidoc-crm.org/crm-concepts/E22</lido:conceptID>
			<lido:term xml:lang="en">Human-Made Object</lido:term>
		</lido:category>
	</xsl:template>

	<xsl:template name="objectClassificationWrap">
		<lido:objectClassificationWrap>
			<xsl:call-template name="objectWorkTypeWrap" />
			<xsl:call-template name="classificationWrap" />
		</lido:objectClassificationWrap>
	</xsl:template>

	<!-- dryer LIDO -->
	<xsl:template name="conceptTerm">
		<lido:conceptID>
			<xsl:attribute name="lido:source">
				<xsl:value-of select="@instanceName" />
			</xsl:attribute>
			<xsl:attribute name="lido:type">
				<xsl:value-of select="internalID" />
			</xsl:attribute>
			<xsl:value-of select="z:vocabularyReferenceItem/@id" />
		</lido:conceptID>
		<lido:term xml:lang="de">
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue" />
		</lido:term>
	</xsl:template>
	
	<!-- remove garbage from unmapped fields -->
	<xsl:template match="z:dataField|z:moduleReference|z:systemField|z:VocabularyReference"/>

</xsl:stylesheet>