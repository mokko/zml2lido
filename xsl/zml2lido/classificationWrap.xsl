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
        <lido:classificationWrap>
			<xsl:call-template name="sachbegriff"/>
			<xsl:call-template name="objekttyp"/>
			<xsl:call-template name="europeanaType"/>
			<xsl:call-template name="sammlung2"/>
			<xsl:call-template name="dreiWege"/>
        </lido:classificationWrap>
	</xsl:template>

	<!-- RIA:Sachbegriff-->
	<xsl:template name="sachbegriff">
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
		<xsl:if test="z:vocabularyReference[
			@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem[
			z:formattedValue = $klassifizierendeTypen]">
			<xsl:message>
				<xsl:text>Objekttyp für Klassifikation: </xsl:text>
				<xsl:value-of select="z:vocabularyReference[
					@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</xsl:message>
			<lido:classification lido:type="Objekttyp">
				<lido:term xml:lang="de">
					<xsl:value-of select="z:vocabularyReference[
						@name = 'ObjCategoryVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:term>
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


	<!-- obsolete not used anymore-->
	<xsl:template name="sammlung">
		<lido:classification lido:type="Sammlung">
			<lido:term lido:addedSearchTerm="no" xml:lang="de">
				<xsl:value-of select="func:vocmap-replace('Sammlung', z:systemField[@name = '__orgUnit'], 'DDB')" />
			</lido:term>
		</lido:classification>	
	</xsl:template>

	<!-- 
		classification from RIA:Bereich
		New version which uses z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue 
	-->
	<xsl:template name="sammlung2">
		<lido:classification lido:type="Sammlung">
			<lido:term lido:addedSearchTerm="no" xml:lang="de">
				<xsl:variable name="sammlung" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue " />
				<xsl:value-of select="replace($sammlung, '^[a-zA-Z]+-','')"/>
			</lido:term>
		</lido:classification>	
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
			<xsl:comment> Daten für die DDB sollen getrennt werden, je nachdem ob sie bei 3 Wege benutzt werden 
			oder nicht. Um dies zu ermöglichen, sind Daten für 3 Wege hier als solche ausgezeichnet.</xsl:comment>
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
</xsl:stylesheet>