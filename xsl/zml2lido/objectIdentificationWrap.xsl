<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:import href="titleWrap.xsl" />
	<xsl:import href="repositoryWrap.xsl" />
	<xsl:import href="objectDescriptionWrap.xsl" />
	<xsl:import href="objectMeasurementsWrap.xsl" />

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="objectIdentificationWrap">
        <lido:objectIdentificationWrap>
            <xsl:call-template name="titleWrap"/>
			<!-- 1.12.2021 Frank schreibt, dass Aufschriften etc. nicht in LIDO ausgegeben werden sollen 
            xsl:call-template name="inscriptionsWrap"/-->
            <xsl:call-template name="repositoryWrap"/>
            <!-- lido:displayStateEditionWrap: A wrapper for the state and edition of the object / work (optional) -->
            <xsl:call-template name="objectDescriptionWrap"/>
            <xsl:call-template name="objectMeasurementsWrap"/>
        </lido:objectIdentificationWrap>
    </xsl:template>


    <xsl:template name="inscriptionsWrap">
		<xsl:apply-templates select="z:repeatableGroup[@name='ObjLabelObjectGrp']"/>
	</xsl:template>
	<xsl:template match="z:repeatableGroup[@name='ObjLabelObjectGrp']">
		<lido:inscriptionsWrap>
			<xsl:apply-templates select="z:repeatableGroupItem">
				<xsl:sort select="z:dataField[@name='SortLnu']"/>
			</xsl:apply-templates>
		</lido:inscriptionsWrap>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjLabelObjectGrp']/z:repeatableGroupItem">
		<lido:inscriptions>
			<xsl:attribute name="lido:sortorder" select="z:dataField[@name='SortLnu']"/>
			<xsl:if test="z:dataField[@name='LabelClb'] or z:dataField[@name='TransliterationClb'] 
				or z:dataField[@name='TranslationClb']">
				<!-- spec inscriptionTranscription: Repeat this element only for language variants, 
				but I also need it for multiple transcriptions: 
				Example 
				1. Japanese handwriting, 
				2. transliteration in German alphabet
				3. tanslation in German
				There is no lido:type for inscriptionTranscription
				-->
				<xsl:apply-templates select="z:dataField[@name='LabelClb']/z:value"/>
				<xsl:apply-templates select="z:dataField[@name='TransliterationClb']/z:value"/>
				<xsl:apply-templates select="z:dataField[@name='TranslationClb']/z:value"/>
			</xsl:if>
			<xsl:apply-templates select="z:dataField[@name='MethodTxt']/z:value"/>
			<xsl:apply-templates select="z:dataField[@name='PositionTxt']/z:value"/>
			<xsl:apply-templates select="z:dataField[@name='OrientationTxt']/z:value"/>
			
		</lido:inscriptions>
	</xsl:template>

	<!-- descriptions -->
	<xsl:template match="z:dataField[@name='MethodTxt']/z:value">
		<lido:inscriptionDescription lido:type="Method">
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:value-of select="."/>
			</lido:descriptiveNoteValue>
		</lido:inscriptionDescription>
	</xsl:template>

	<xsl:template match="z:dataField[@name='PositionTxt']/z:value">
		<lido:inscriptionDescription lido:type="Position">
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:value-of select="."/>
			</lido:descriptiveNoteValue>
		</lido:inscriptionDescription>
	</xsl:template>

	<xsl:template match="z:dataField[@name='OrientationTxt']/z:value">
		<lido:inscriptionDescription lido:type="Ausrichtung">
			<lido:descriptiveNoteValue xml:lang="de">
				<xsl:value-of select="."/>
			</lido:descriptiveNoteValue>
		</lido:inscriptionDescription>
	</xsl:template>

	<!-- transcriptions -->
	<xsl:template match="z:dataField[@name='LabelClb']/z:value">
		<lido:inscriptionTranscription xml:lang="de" lido:label="Aufschrift">
			<xsl:value-of select="."/>
		</lido:inscriptionTranscription>
	</xsl:template>

	<xsl:template match="z:dataField[@name='TransliterationClb']/z:value">
		<lido:inscriptionTranscription xml:lang="de" lido:label="Transliteration">
			<xsl:value-of select="."/>
		</lido:inscriptionTranscription>
	</xsl:template>

	<xsl:template match="z:dataField[@name='TranslationClb']/z:value">
		<lido:inscriptionTranscription xml:lang="de" lido:label="Überschrift">
			<xsl:value-of select="."/>
		</lido:inscriptionTranscription>
	</xsl:template>
</xsl:stylesheet>