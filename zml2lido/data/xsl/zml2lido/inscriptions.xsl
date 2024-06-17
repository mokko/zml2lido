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
	From Lido 1.1. spec: "A set of the textual transcription or description of any 
	distinguishing or identifying physical lettering, annotations, texts, markings, or 
	labels that are affixed, applied, stamped, written, inscribed, or attached to the 
	object/work, excluding any mark or text inherent in the materials of which it is 
	made."

	ccc-Inschriften sind intrinsisch für das Objekt, ccc-Aufschriften nicht.
	Nach der Spec sind lido:inscriptions immer extrinsisch, was m.E. keinen Sinn macht. 
	Also notieren wir alle In- oder Aufschriften als lido:Inscriptions.

	In RIA ist "Aufschrift" ist Oberbegriff für alle In- und Aufschriften, was auch keinen 
	Sinn macht, weil sich widersprechende Definitionen.

	Lido 1.0 empfiehlt Wasserzeichen als Display Materials/Techniques zu beschreiben. Daraus 
	könnte man entnehmen, dass Inschriften allgemein in Material/Technik erfasst werden 
	sollen.

	lido:inscriptions are repeatable
	-->


    <xsl:template name="inscriptionsWrap">
		<xsl:apply-templates select="z:repeatableGroup[@name='ObjLabelObjectGrp']"/>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjLabelObjectGrp']">
		<lido:inscriptionsWrap>
			<!--xsl:message>
				<xsl:text>sorttest: </xsl:text>
				<xsl:value-of select="z:repeatableGroupItem/z:dataField[@name='SortLnu']"/>
			</xsl:message-->
			<xsl:apply-templates select="z:repeatableGroupItem">
				<!-- sorting untested-->
				<xsl:sort select="z:repeatableGroupItem/z:dataField[@name='SortLnu']"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="z:repeatableGroupItem/z:dataField[@name='TransliterationClb']/z:value"/>
			<xsl:apply-templates select="z:repeatableGroupItem/z:dataField[@name='TranslationClb']/z:value"/>
		</lido:inscriptionsWrap>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjLabelObjectGrp']/z:repeatableGroupItem">
		<!-- 
		Why are lido:inscriptions not called inscriptionSet? 
		-->

		<lido:inscriptions>
			<xsl:variable name="sortorder" select="z:dataField[@name='SortLnu']/z:value"/>

			<xsl:attribute name="lido:sortorder"><!--as="xs:number"-->
				<xsl:choose>
					<xsl:when test="$sortorder ne ''">
						<xsl:value-of select="$sortorder"/>
					</xsl:when>
					<!-- default value-->
					<xsl:otherwise>10</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:variable name="type" select="z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue"/>
			<!--xsl:message>
				<xsl:text>Aufschriftstyp: </xsl:text>
				<xsl:value-of select="$type"/>				
			</xsl:message-->
			<xsl:attribute name="lido:type">
				<xsl:value-of select="$type"/>
			</xsl:attribute>
			<xsl:comment>
			For SMB, inscriptions can be external or internal to the object as determined
			by type.

			We now provide multiple inscriptions (in line with LIDO 1.0/1.1) for mere 
			copies, translations and transliterations. Our subfields for 
			inscriptionDescription are output as text (in column style).</xsl:comment>
			
			<!-- 
			According to spec, lido:inscriptionTranscription should only be repeated for
			language variants (i.e. translations). Makes little sense if 
			inscription/transcription and translation are already two versions. So we
			multiple.
			Apprently, lido:transcription refers to any version of the original text 
			implying that the original remains at the original and cannot be included 
			here. That's plausible enough.

			LabelClb: AufschriftInhalt
			TranslationClb: Übersetzung
			TransliterationClb: TextTranskription
			-->
			
			<xsl:apply-templates select="z:dataField[@name='LabelClb']/z:value"/>

			<!-- 
			inscriptionDescription: Wrapper for a description of the inscription
			lido:sourceDescriptiveNote should nit be repeated. In this case we follow the 
			spec, while for inscriptionTranscription we only deliver one
			-->
			<xsl:variable name="Art" select="z:vocabularyReference[
				@name='CategoryVoc'
			]/z:vocabularyReferenceItem/z:formattedValue[
				@language = 'de'
			]"/>
			<xsl:variable name="Ausführung" select="z:dataField[@name='InscriberTxt']/z:value"/>
			<xsl:variable name="Ausrichtung" select="z:dataField[@name='OrientationTxt']/z:value"/>
 		    <xsl:variable name="Authentizität" select="z:vocabularyReference[
			@name='AuthenticityVoc'
			]/z:vocabularyReferenceItem/z:formattedValue[
				@language = 'de'
			]"/>
			<xsl:variable name="Bemerkung" select="z:dataField[@name='NotesClb']/z:value"/>
			<xsl:variable name="Datierung" select="z:dataField[@name='DateTxt']/z:value"/>
			<xsl:variable name="Methode" select="z:dataField[@name='MethodTxt']/z:value"/>
			<xsl:variable name="Position" select="z:dataField[@name='PositionTxt']/z:value"/>
 		    <xsl:variable name="Quelle" select="z:moduleReference[
				@name='LiteratureRef'
			]/z:moduleReferenceItem/z:formattedValue[
				@language = 'de'
			]"/>
			<xsl:variable name="Schrift" select="z:dataField[@name='LetteringTxt']/z:value"/>			

			<xsl:if test="($Art, $Ausführung, $Ausrichtung, $Authentizität, $Bemerkung, 
				$Datierung, $Methode, $Quelle, $Position, $Schrift) != ''">
				<lido:inscriptionDescription>
					<lido:descriptiveNoteValue xml:lang="de">
						<xsl:for-each select="$Art, $Ausführung, $Ausrichtung, $Authentizität, $Bemerkung, $Datierung, $Methode, $Position, $Schrift">
							<xsl:apply-templates select="."/>
							<xsl:if test="position() != last()">
							  <xsl:text>; </xsl:text>
						    </xsl:if>
						</xsl:for-each>
					</lido:descriptiveNoteValue>
					<xsl:apply-templates select="$Quelle"/>
				</lido:inscriptionDescription>
			</xsl:if>
		</lido:inscriptions>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[
			@name='CategoryVoc'
		]/z:vocabularyReferenceItem/z:formattedValue[
			@language = 'de'
		]">
		<xsl:text>Art: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:dataField[@name='InscriberTxt']/z:value">
		<xsl:text>Ausführung: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[
		@name='AuthenticityVoc'
		]/z:vocabularyReferenceItem/z:formattedValue[
			@language = 'de'
		]">
		<xsl:text>Authentizität: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:dataField[@name='NotesClb']/z:value">
		<xsl:text>Bemerkung: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:dataField[@name='DateTxt']/z:value">
		<xsl:text>Datierung: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:dataField[@name='MethodTxt']/z:value">
		<xsl:text>Method: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="z:dataField[@name='PositionTxt']/z:value">
		<xsl:text>Position: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<!--Quelle-->
	<xsl:template match="z:moduleReference[
				@name='LiteratureRef'
			]/z:moduleReferenceItem/z:formattedValue[
				@language = 'de'
			]">
		<lido:sourceDescriptiveNote xml:lang="de">
			<xsl:value-of select="."/>
		</lido:sourceDescriptiveNote>
	</xsl:template>

	<xsl:template match="z:dataField[@name='LetteringTxt']/z:value">
		<xsl:text>Schrift: </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>


	<!-- transcriptions -->
	<!-- ccc Projekt trennt zwischen Aufschrift und Inschrift. 
	ccc-Inschriften sind intrinsisch für das Objekt, ccc-Aufschriften nicht.
	lido:inscriptions sind immer extrinsisch. Dieser absurden LIDO-Definition
    widerspricht das ccc-Portal.
	-->
	<xsl:template match="z:dataField[@name='LabelClb']/z:value">
		<lido:inscriptionTranscription lido:label="Aufschrift">
			<xsl:variable name="type" select="../../z:vocabularyReference[
				@name='TypeVoc'
			]/z:vocabularyReferenceItem/z:formattedValue"/>
			<xsl:variable name="lang" select="../../z:vocabularyReference[
				@name='LanguageVoc'
			]/z:vocabularyReferenceItem/z:formattedValue"/>
			<xsl:attribute name="xml:lang">
				<xsl:choose>
					<xsl:when test="$lang ne ''">
						<xsl:value-of select="$lang"/>
					</xsl:when>
					<!--default value-->
					<xsl:otherwise>
						<xsl:text>de</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute> 
			<xsl:if test="$type ne ''">
				<xsl:attribute name="lido:type">
					<!-- Allg. Angabe Beschriftung -->
					<xsl:value-of select="$type"/>				
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</lido:inscriptionTranscription>
	</xsl:template>

	<xsl:template match="z:dataField[@name='TransliterationClb']/z:value">
		<xsl:variable name="sortorder" select="../../z:dataField[@name='SortLnu']/z:value"/>
		<!--xsl:message>
			<xsl:text>sorttest2: </xsl:text>
			<xsl:value-of select="$sortorder"/>
		</xsl:message-->
		<lido:inscriptions lido:label="Transliteration">
			<xsl:if test="$sortorder ne ''">
				<xsl:attribute name="lido:sortorder">
					<xsl:value-of select="$sortorder"/>
				</xsl:attribute>
			</xsl:if>
			<lido:inscriptionTranscription>
				<xsl:value-of select="."/>
			</lido:inscriptionTranscription>
		</lido:inscriptions>
	</xsl:template>

	<xsl:template match="z:dataField[@name='TranslationClb']/z:value">
		<xsl:variable name="sortorder" select="../../z:dataField[@name='SortLnu']/z:value"/>
		<!--xsl:message>
			<xsl:text>sorttest3: </xsl:text>
			<xsl:value-of select="$sortorder"/>
		</xsl:message-->
		<lido:inscriptions lido:type="Übersetzung">
			<xsl:if test="$sortorder ne ''">
				<xsl:attribute name="lido:sortorder">
					<xsl:value-of select="$sortorder"/>
				</xsl:attribute>
			</xsl:if>
			<lido:inscriptionTranscription>
				<xsl:value-of select="."/>
			</lido:inscriptionTranscription>
		</lido:inscriptions>
	</xsl:template>
</xsl:stylesheet>