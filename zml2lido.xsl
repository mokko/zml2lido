<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:lido="http://www.lido-schema.org" 
	exclude-result-prefixes="z" 
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	
	<xsl:import href="zml2lido/objectWorkTypeWrap.xsl" />
	<xsl:import href="zml2lido/classificationWrap.xsl" />
	<xsl:import href="zml2lido/objectIdentificationWrap.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<lido:lidoWrap>
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Object']" />
		</lido:lidoWrap>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem">
		<lido:lido>
			<lido:lidoRecID><xsl:value-of select="@id" /></lido:lidoRecID>
            <xsl:call-template name="category"/>

            <lido:descriptiveMetadata xml:lang="de">
                <xsl:call-template name="objectClassificationWrap"/>
                <xsl:call-template name="objectIdentificationWrap"/>
                <xsl:call-template name="eventWrap"/>
                <xsl:call-template name="objectRelationWrap"/>
            </lido:descriptiveMetadata>

            <lido:administrativeMetadata xml:lang="en">
                <xsl:call-template name="rightsWorkWrap"/>
                <xsl:call-template name="recordWrap"/>
                <xsl:call-template name="resourceWrap"/>
            </lido:administrativeMetadata>
		</lido:lido>
	</xsl:template>

	<xsl:template name="category">
		<!-- Not sure how to map this, perhaps introduce a new Objekttyp upstream-->
		<lido:category>
		   <lido:conceptID lido:type="URI">http://www.cidoc-crm.org/crm-concepts/E22</lido:conceptID>
		   <lido:term xml:lang="en">Human-Made Object</lido:term>
		</lido:category>
	</xsl:template>

	<xsl:template name="objectClassificationWrap">
        <lido:objectClassificationWrap>
            <xsl:call-template name="objectWorkTypeWrap"/>
            <xsl:call-template name="classificationWrap"/>
        </lido:objectClassificationWrap>
    </xsl:template>

	<xsl:template name="eventWrap"/>
	<xsl:template name="objectRelationWrap"/>
	
	<xsl:template name="rightsWorkWrap"/>
	<xsl:template name="recordWrap"/>
	<xsl:template name="resourceWrap"/>
	
	<!-- dryer LIDO -->
	<xsl:template name="conceptTerm">
		<lido:conceptID>
			<xsl:attribute name="source">
				<xsl:value-of select="@instanceName"/>
			</xsl:attribute>
			<xsl:value-of select="z:vocabularyReferenceItem/@id"/>
		</lido:conceptID>
		<lido:term xml:lang="de">
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue"/>
		</lido:term>
	</xsl:template>
</xsl:stylesheet>