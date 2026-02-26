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
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjTextOnlineGrp']/z:repeatableGroupItem"/>
			<!--xsl:apply-templates select="z:repeatableGroup[@name='ObjAcquisitionNotesGrp']/z:repeatableGroupItem"/-->
		</lido:objectDescriptionWrap>
    </xsl:template>
	<!-- [z:vocabularyReference/z:vocabularyReferenceItem/@name='Ausgabe']-->


	<!--only online Beschreibung, other beschreibungstexte are not approved for online use -->
	<xsl:template match="z:repeatableGroup[@name='ObjTextOnlineGrp']/z:repeatableGroupItem">
		<!--xsl:message>
			<xsl:value-of select="z:dataField[@name='TextClb']"/>
		</xsl:message-->
		<xsl:variable name="text" select="z:dataField[@name='TextHTMLClb']"/>
		<xsl:choose>
			<xsl:when test="$text = '[SM8HF]' or $text = '[Benin_Königreich]'">
			</xsl:when>
			<xsl:when test="contains($text, '[SM8HF]' )">
				<xsl:call-template name="onlineText">
					<xsl:with-param name="txt" select="replace($text, '\[SM8HF\]', '')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, '[Benin_Königreich]' )">
				<xsl:call-template name="onlineText">	
					<xsl:with-param name="txt" select="replace($text, '\[Benin_Königreich\]', '')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="onlineText">
					<xsl:with-param name="txt" select="$text"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="onlineText">
		<xsl:param name="txt"/>
		<lido:objectDescriptionSet lido:type="Objektbeschreibung">
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:attribute name="lido:encodinganalog">
					<xsl:value-of select="z:vocabularyReference/z:vocabularyReferenceItem/@name"/>
				</xsl:attribute> 
				<xsl:value-of select="normalize-space($txt)"/>
				<!--xsl:message>
					<xsl:value-of select="$txt"/>
				</xsl:message-->
			</lido:descriptiveNoteValue>
		</lido:objectDescriptionSet>
	</xsl:template>
	
	<!--xsl:template match="z:repeatableGroup[@name='ObjAcquisitionNotesGrp']/z:repeatableGroupItem">
		<lido:objectDescriptionSet lido:type="Erwerbung">
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:attribute name="lido:encodinganalog">
					<xsl:value-of select="z:dataField/z:value"/>
				</xsl:attribute> 
				<xsl:value-of select="z:dataField[@name='TextClb']"/>
			</lido:descriptiveNoteValue>
		</lido:objectDescriptionSet>
	</xsl:template-->
</xsl:stylesheet>