<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z func"	
	xmlns:func="http://func"
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
		<!--unlikely that all of them are empty-->
        <lido:classificationWrap>
			<xsl:call-template name="dreiWege"/>
			<xsl:call-template name="europeanaType"/>
			<xsl:call-template name="genericAAT"/>
			<xsl:call-template name="objekttyp"/>
			<xsl:call-template name="objekttyp2aat"/>
			<xsl:call-template name="sachbegriff"/>
			<xsl:call-template name="sammlung2"/>
			<xsl:call-template name="systematikArt"/>
        </lido:classificationWrap>
	</xsl:template>

	<!-- 
		classification specific to 3 Wege project
		Gruppen und Freigaben müssen hier aufgezählt werden, damit sie entsprechend gekennzeichnet werden 
		3Wege:
			getPack group 117396 Boxeraufstand200
			getPack group 106400 Musik100
			getPack approval 4460851 Benin
			getPack group 101396 AKuOstasien42
			getPack group 162397 Walzen
			getPack group 163396 AfrikaSM
			pack
	-->
	<xsl:template name="dreiWege">
		<!-- 
			Daten für die DDB sollen getrennt werden, je nachdem ob sie bei 3 Wege benutzt werden 
			oder nicht. Um dies zu ermöglichen, sind Daten für 3 Wege hier als solche ausgezeichnet.
		-->
		<xsl:variable name="grpIds" select="
			'101396',
			'106400',
			'117396', 
			'163396',
			'162397'
		"/>
		<xsl:apply-templates select="z:moduleReference[@name = 'ObjObjectGroupsRef']/z:moduleReferenceItem[@moduleItemId = $grpIds]"/>
		<xsl:apply-templates mode="DDB" select="z:repeatableGroup[@name = 'ObjPublicationGrp']
			/z:repeatableGroupItem[z:vocabularyReference/z:vocabularyReferenceItem/@name = 'DatenFreigegebenfürEMBeninProjekt']"/>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name = 'ObjObjectGroupsRef']/z:moduleReferenceItem">
		<lido:classification lido:type="DDB">
			<lido:term lido:addedSearchTerm="no">3 Wege</lido:term>
		</lido:classification>
	</xsl:template>

	<!-- Im Augenblick gibt es nur eine ApprovalGrp, die für 3 Wege freigegeben ist -->
	<xsl:template mode="DDB" match="z:repeatableGroup[@name = 'ObjPublicationGrp']/z:repeatableGroupItem[
		z:vocabularyReference/z:vocabularyReferenceItem/@name = 'DatenFreigegebenfürEMBeninProjekt']">
		<xsl:if test="z:vocabularyReference[@name = 'PublicationVoc']/z:vocabularyReferenceItem/z:formattedValue">
			<lido:classification lido:type="DDB">
				<lido:term lido:addedSearchTerm="no">3 Wege</lido:term>
			</lido:classification>
		</xsl:if>
	</xsl:template>


	<!-- europeanaType-->
	<xsl:template name="europeanaType">
		<!-- 2nd classification for ontologically wrong europeana:type-->
		<lido:classification lido:type="europeana:type">
			<xsl:comment>europeana:type refers to a resource of the representation in the description of the object. 
			This seems ontologically wrong. Seems to be remnant of old/first EUROPEANA data structure.</xsl:comment>
			<lido:term lido:addedSearchTerm="no">IMAGE</lido:term>
		</lido:classification>
	</xsl:template>


	<!-- AAT -->
	<xsl:template name="genericAAT">
		<xsl:variable name="bereich" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:variable name="kunstmuseen" select="
			'AKU', 
			'ISL',
			'KK'
		"/>
		<xsl:variable name="archäologischeBereiche" select="
			'EM-Am Archäologie' 
		"/>
		<xsl:variable name="ethnologischeBereiche" select="
			'EM-Afrika', 
			'EM-Am Ethnologie',
			'EM-Musikethnologie',
			'EM-Nordafrika, West- und Zentralasien',
			'EM-Ost- und Nordasien',
			'EM-Ozeanien',
			'EM-Phonogramm-Archiv',
			'EM-Süd- und Süstostasien',
		"/>
		<xsl:if test="normalize-space(substring-before($bereich, '-')) = $kunstmuseen">
			<lido:classification>
				<!-- art; better than art work? -->
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/aat/300417586</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">art</lido:term>
			</lido:classification>
		</xsl:if>
		
		<!-- ISL. Why this extrawurst? -->
		<xsl:if test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem/@moduleItemId = '67676' "> 
			<lido:classification>
				<!-- art; better than art work? -->
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/aat/300417586</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">art</lido:term>
			</lido:classification>
		</xsl:if>
		
		<xsl:if test="$bereich = $archäologischeBereiche">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/aat/300234110</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">archaeologic object</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = $ethnologischeBereiche">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/aat/300234108</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">ethnographic object</lido:term>
			</lido:classification>
		</xsl:if>

		<!-- einzelne Bereiche -->
		
		<xsl:if test="$bereich = 'EM-Afrika'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/aat/300015647</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">African</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = 'EM-Ost- und Nordasien' or $bereich = 'EM-Süd- und Süstostasien'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300018279</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">Asian</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = 'EM-Ozeanien'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300021854</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">Oceanic</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = 'EM-Musikethnologie'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300054146</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">music (performing arts genre)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = 'EM-Phonogramm-Archiv'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300028633</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">sound recordings</lido:term>
			</lido:classification>

			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300265798</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">cylinder phonographs (phonographs)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = 'EM-Medienarchiv'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300429823</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">recordings</lido:term>
			</lido:classification>
		</xsl:if>
	</xsl:template>


	<!-- objekttyp-->
	<xsl:template name="objekttyp">
		<xsl:variable name="klassifizierendeTypen" select="
			'Druckgrafik',
			'Malerei/Gemälde',
			'Fotografie',
			'Installation',
			'Musikinstrument',
			'Skulptur/Plastik/Objektkunst',
			'Textilie',
			'Zeichnung'
		"/>
		<xsl:variable name="objekttyp" select="z:vocabularyReference[
			@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem[
			z:formattedValue]"/>
		<!-- this will not select specialized sachbegriffe like EM-Sachbegriff TODO FIX! -->
		<xsl:variable name="sachbegriffe" select="z:dataField[@name = 'ObjTechnicalTermClb']/z:value"/>
		<!--xsl:message>
			<xsl:text>Sachbegriffe: </xsl:text>
			<xsl:value-of select="$sachbegriffe"/>
		</xsl:message-->

		<xsl:if test="$objekttyp = $klassifizierendeTypen">
			<!-- only add classification from Objekttyp, if Objekttyp is not already in Sachbegriff-->
			<xsl:if test="not($sachbegriffe = $objekttyp)">
				<!--xsl:message>
					<xsl:text>INFO classification from Objekttyp: </xsl:text>
					<xsl:value-of select="$objekttyp"/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="../@name"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="@id"/>
					<xsl:text>)</xsl:text>
				</xsl:message-->
				<lido:classification lido:type="RIA:Objekttyp">
					<lido:term xml:lang="de">
						<xsl:value-of select="$objekttyp"/>
					</lido:term>
				</lido:classification>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="objekttyp2aat">
		<xsl:variable name="objekttyp" select="z:vocabularyReference[
		@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem[
		z:formattedValue]"/>

		<xsl:if test="$objekttyp eq 'Druckgrafik'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300131119</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">printmaking</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Malerei/Gemälde'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300033618</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">paintings (visual works)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Fotografie'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300054225</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">photography (process)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Installation'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300047896</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">installations (visual works)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Musikinstrument'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300041620</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">musical instruments</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Skulptur/Plastik/Objektkunst'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300047090</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">sculpture (visual works)</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Textilie'">
			<!-- lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300041620</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">musical instruments</lido:term>
			</lido:classification-->
		</xsl:if>

		<xsl:if test="$objekttyp eq 'Zeichnung'">
			<lido:classification>
				<lido:conceptID lido:source="AAT" lido:type="uri">http://vocab.getty.edu/page/aat/300033973</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">drawings (visual works)</lido:term>
			</lido:classification>
		</xsl:if>
	</xsl:template>

	<!-- sachbegriff -->
	<xsl:template name="sachbegriff">
		<xsl:choose>
			<!-- specific to EM; EM-Sachbegriff Thesaurus -->
			<xsl:when test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem[@moduleItemId = '67678']">
				<xsl:apply-templates mode="classification" select="z:repeatableGroup[@name ='ObjTechnicalTermGrp']
					/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermEthnologicalVoc']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="classification" select="z:dataField[@name = 'ObjTechnicalTermClb']/z:value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="classification" match="z:dataField[@name = 'ObjTechnicalTermClb']/z:value">
		<lido:classification lido:type="RIA:Sachbegriff">
			<lido:term xml:lang="de">
				<xsl:value-of select="normalize-space(.)"/>
			</lido:term>
		</lido:classification>
	</xsl:template>

	<xsl:template mode="classification" match="z:repeatableGroup[@name ='ObjTechnicalTermGrp']
		/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermEthnologicalVoc']">
		<lido:classification lido:type="RIA:EM-Sachbegriff">
			<xsl:call-template name="conceptTerm"/>
		</lido:classification>
	</xsl:template>	


	<!-- 
		classification from RIA:Bereich
		New version which uses z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue
		Sammlung is Bereich without the Verwaltende Institution
	-->
	<xsl:template name="sammlung2">
		<xsl:variable name="sammlung" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:variable name="sammlung2">
			<xsl:choose>
				<xsl:when test="$sammlung ne ''">
					<xsl:value-of select="normalize-space(replace($sammlung, '^[a-zA-Z]+-',''))"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- 
						I dont know why ISL-Fotos has no ObjOrgGroupVoc. Let's investigate...
						not a proper solution 
					-->
					<xsl:choose>
						<!-- ISL -->
						<xsl:when test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem/@moduleItemId = '67676'">
							<xsl:value-of select="normalize-space(replace(z:systemField[@name='__orgUnit'], '^ISL',''))"/>
						</xsl:when>
						<!-- KB -->
						<xsl:when test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem/@moduleItemId = '73768'">
							<xsl:value-of select="normalize-space(replace(z:systemField[@name='__orgUnit'], '^KB',''))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message terminate="yes">
								<xsl:text>UNKNOWN INSTITUTION: PLEASE TEACH ME</xsl:text>
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		
		<!--xsl:message>
			<xsl:text>Sammlung2: </xsl:text>
			<xsl:value-of select="$sammlung2"/>
		</xsl:message-->
		<xsl:if test="$sammlung2 ne ''">
			<lido:classification lido:type="Sammlung">
				<lido:term lido:addedSearchTerm="no" xml:lang="de">
					<xsl:value-of select="$sammlung2"/>
				</lido:term>
			</lido:classification>
		</xsl:if>	
	</xsl:template>


	<!-- systematikArt -->
	<xsl:template name="systematikArt">
		<xsl:if test="normalize-space(z:dataField[@name = 'ObjSystematicClb']/z:value) ne ''">
			<lido:classification>
				<xsl:comment>SystematikArt</xsl:comment>
				<lido:term xml:lang="de">
					<xsl:value-of select="normalize-space(z:dataField[@name = 'ObjSystematicClb']/z:value)"/>
				</lido:term>
			</lido:classification>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>