<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
    exclude-result-prefixes="z func"	
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
			<xsl:call-template name="bereich2aat"/>
			<xsl:call-template name="bereich3"/>
			<xsl:call-template name="objekttyp3"/>
			<xsl:call-template name="sachbegriff"/>
			<xsl:call-template name="systematikArt"/>
			<xsl:call-template name="europeanaType"/>
        </lido:classificationWrap>
	</xsl:template>


	<!-- bereich2AAT -->
	<xsl:template name="bereich2aat">
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
			'EM-Süd- und Süstostasien'
		"/>
		<xsl:if test="normalize-space(substring-before($bereich, '-')) = $kunstmuseen">
			<lido:classification>
				<!-- art; better than art work? -->
				<lido:conceptID 
					lido:encodinganalog="RIA:Bereichskürzel" 
					lido:source="Art &amp; Architecture Thesaurus" 
					lido:type="uri">http://vocab.getty.edu/aat/300417586</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">art</lido:term>
			</lido:classification>
		</xsl:if>
		
		<!-- ISL. Why this extrawurst? -->
		<xsl:if test="z:moduleReference[@name = 'ObjOwnerRef']/z:moduleReferenceItem/@moduleItemId = '67676' "> 
			<lido:classification>
				<!-- art; better than art work? -->
				<lido:conceptID lido:encodinganalog="RIA:verwaltendeInstitution" lido:source="Art &amp; Architecture Thesaurus" lido:type="uri">http://vocab.getty.edu/aat/300417586</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">art</lido:term>
			</lido:classification>
		</xsl:if>
		
		<xsl:if test="$bereich = $archäologischeBereiche">
			<lido:classification>
				<lido:conceptID 
					lido:encodinganalog="RIA:Bereich" 
					lido:source="Art &amp; Architecture Thesaurus" 
					lido:type="uri">http://vocab.getty.edu/aat/300234110</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">archaeologic object</lido:term>
			</lido:classification>
		</xsl:if>

		<xsl:if test="$bereich = $ethnologischeBereiche">
			<lido:classification>
				<lido:conceptID 
					lido:encodinganalog="RIA" 
					lido:source="Art &amp; Architecture Thesaurus" 
					lido:type="uri">http://vocab.getty.edu/aat/300234108</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="yes">ethnographic object</lido:term>
			</lido:classification>
		</xsl:if>
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


	<!-- 
		Marker für 3Wege bzw. CCC-Portal. Derzeit benutzen wir keinen Marker
	-->

	<!-- europeanaType-->
	<xsl:template name="europeanaType">
		<!-- 2nd classification for ontologically wrong europeana:type-->
		<lido:classification lido:type="europeana:type">
			<xsl:comment>europeana:type refers to a resource of the representation in the description of the object. 
			This seems ontologically wrong. Seems to be remnant of old/first EUROPEANA data structure.</xsl:comment>
			<lido:term lido:addedSearchTerm="no">IMAGE</lido:term>
		</lido:classification>
	</xsl:template>

	<xsl:template name="objekttyp3">
		<!-- i had trouble extracting objekttyp-->
		<xsl:variable name="objekttyp" select="z:vocabularyReference[@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:if test="$objekttyp ne ''">
			<xsl:variable name="objekttypControl" select="func:vocmap-control('Objekttyp',$objekttyp)"/>
			<xsl:variable name="aaturi" select="func:vocmap-replace-laxer('Objekttyp',$objekttyp, 'aaturi')"/>
			<xsl:variable name="aatlabel" select="func:vocmap-replace-lax-lang('Objekttyp',$objekttyp, 'aatlabel', 'en')"/>
				
			<xsl:if test="$objekttypControl ne ''">		
				<!--xsl:message>
					<xsl:text>classification from Objekttyp </xsl:text>
					<xsl:value-of select="$objekttyp"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="@id"/>
				</xsl:message-->
				<xsl:comment>Objekttyp für CCC-Portal</xsl:comment>
				<lido:classification type="Objekttyp">
					<lido:conceptID lido:encodinganalog="RIA:Objekttyp" lido:source="ObjCategoryVoc" lido:type="local"/>
					<lido:term xml:lang="de">
						<xsl:value-of select="$objekttypControl"/>
					</lido:term>
				</lido:classification>
			</xsl:if>
			<xsl:if test="$aaturi ne ''">		
				<lido:classification>
					<lido:conceptID lido:encodinganalog="RIA:Objekttyp" 
						lido:source="Art &amp; Architecture Thesaurus" 
						lido:type="uri">
							<xsl:value-of select="$aaturi"/>
					</lido:conceptID>
					<xsl:if test="$aatlabel ne ''">		
						<lido:term lido:addedSearchTerm="yes" xml:lang="en">
							<xsl:value-of select="$aatlabel"/>
						</lido:term>
					</xsl:if>
				</lido:classification>
			</xsl:if>
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
		<lido:classification>
			<!-- 
				source not allowed in classification or term
				ObjTechnicalTermClb provides no ID
			-->
			<lido:conceptID lido:encodinganalog="RIA:Sachbegriff" lido:source="RIA:Sachbegriff" lido:type="local"/>
			<lido:term xml:lang="de">
				<xsl:value-of select="normalize-space(.)"/>
			</lido:term>
		</lido:classification>
	</xsl:template>

	<xsl:template mode="classification" match="z:repeatableGroup[@name ='ObjTechnicalTermGrp']
		/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermEthnologicalVoc']">
		<lido:classification>
			<xsl:call-template name="conceptTerm"/>
		</lido:classification>
	</xsl:template>	

	<!-- 
		classification from RIA:Bereich
		New version which uses z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue
		Sammlung is Bereich without the Verwaltende Institution
	-->
	<xsl:template name="bereich3">
		<xsl:variable name="bereich" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:variable name="aaturi" select="func:vocmap-replace-laxer('Bereich',$bereich, 'aaturi')"/>
		<xsl:variable name="aatlabel" select="func:vocmap-replace-laxer('Bereich',$bereich, 'aatlabel')"/>
		<!--
		1.6.2024 Sammlung soll nicht classification sein.
		<xsl:variable name="sammlung" select="func:vocmap-control('Bereich',$bereich)"/>
		<xsl:if test="$sammlung ne ''">		
			xsl:message>
				<xsl:text>classification from Bereich </xsl:text>
				<xsl:value-of select="@id"/>
			</xsl:message
			<lido:classification>
				<lido:conceptID lido:encodinganalog="RIA:Bereich" lido:source="ObjOrgGroupVoc" lido:type="local"/>
				<lido:term xml:lang="de">
					<xsl:value-of select="$sammlung"/>
				</lido:term>
			</lido:classification>
		</xsl:if>
		-->
		<xsl:if test="$aaturi ne ''">		
			<lido:classification>
				<lido:conceptID lido:encodinganalog="RIA:SystematikArt(ObjSystematicClb)" 
					lido:source="Art &amp; Architecture Thesaurus" 
					lido:type="uri">
						<xsl:value-of select="$aaturi"/>
				</lido:conceptID>
				<xsl:if test="$aatlabel ne ''">		
					<lido:term lido:addedSearchTerm="yes" xml:lang="en">
						<xsl:value-of select="$aatlabel"/>
					</lido:term>
				</xsl:if>
			</lido:classification>
		</xsl:if>
	</xsl:template>
	<!-- 
	
	systematikArt 
	The terms in this RIA field often don't make sense, e.g. "31 A - Christusfiguren" so we switch
	to a positive list of the most often used terms
	
	 mpxvok
	-->
	<xsl:template name="systematikArt">
		<xsl:variable name="sysArt" select="z:dataField[@name = 'ObjSystematicClb']/z:value"/>
		<xsl:variable name="sysArtControl" select="func:vocmap-control('systematikArt',$sysArt)"/>
		<xsl:variable name="aaturi" select="func:vocmap-replace-laxer('systematikArt',$sysArt, 'aaturi')"/>
		<xsl:variable name="aatlabel" select="func:vocmap-replace-laxer('systematikArt',$sysArt, 'aatlabel')"/>
		<xsl:if test="$sysArtControl ne ''">		
			<!--xsl:message>
				<xsl:text>classification from systematikArt </xsl:text>
				<xsl:value-of select="@id"/>
			</xsl:message-->
			<lido:classification>
				<lido:conceptID lido:encodinganalog="RIA:SystematikArt" lido:source="ObjSystematicClb" lido:type="local"/>
				<lido:term xml:lang="de">
					<xsl:value-of select="$sysArt"/>
				</lido:term>
			</lido:classification>
		</xsl:if>
		<xsl:if test="$aaturi ne ''">		
			<lido:classification>
				<lido:conceptID lido:encodinganalog="RIA:SystematikArt(ObjSystematicClb)" 
					lido:source="Art &amp; Architecture Thesaurus" 
					lido:type="uri">
						<xsl:value-of select="$aaturi"/>
				</lido:conceptID>
				<xsl:if test="$aatlabel ne ''">		
					<lido:term xml:lang="en">
						<xsl:value-of select="$aatlabel"/>
					</lido:term>
				</xsl:if>
			</lido:classification>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>