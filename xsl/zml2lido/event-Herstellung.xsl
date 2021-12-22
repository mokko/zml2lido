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

	<xsl:template name="Herstellung">
		<xsl:variable name="herstellendeRollen" select="
			'Autor',
			'Bildhauer', 'Bildhauerin',
			'Drucker',					
			'Filmemacher', 
			'Filmregisseur', 
			'Fotograf', 
			'Hersteller', 
			'Inventor', 
			'Künstler', 'Künstlerin','Künstler des Originals',  
			'Maler', 'Malerin',		
			'Zeichner', 'Zeichnerin'
		"/>
		<xsl:variable name="herstellendeKollektive" select="
			'Ethnie',
			'Kultur',
			'Sprachgruppe'
		"/>

		<xsl:variable name="herstellendeOrtstypen" select="'Herstellungsort'"/>
		
		<xsl:variable name="herstellendeRollenN" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $herstellendeRollen]"/>

		<xsl:variable name="herstellendeKollektiveN" select="
			z:repeatableGroup[
				@name = 'ObjGeograficGrp']/
			z:repeatableGroupItem/z:vocabularyReference[
				@name = 'GeopolVoc' 
				and z:vocabularyReferenceItem/@name = $herstellendeKollektive
			]"/>

		<xsl:variable name="herstellendeOrteN" select="
			z:repeatableGroup[
				@name = 'ObjGeograficGrp' 
				and z:repeatableGroupItem/z:vocabularyReference[
					@name = 'TypeVoc' 
					and z:vocabularyReferenceItem/@name = $herstellendeOrtstypen
				]
			]"/>

		<!-- Aufnahmejahr is stupid, but it will exist for some time -->
		<xsl:variable name="herstellendeDatenTypen" select="
			'Aufnahme',
			'Aufnahmejahr', 
			'Herstellung'
		"/>

		<xsl:variable name="herstellendeDatenTypenN" select="
			z:repeatableGroup[
				@name = 'ObjDateGrp']/
			z:repeatableGroupItem[
				z:vocabularyReference[@name = 'TypeVoc']/
				z:vocabularyReferenceItem/@name = $herstellendeDatenTypen
				or not (z:vocabularyReference[@name = 'TypeVoc'])
			]
		"/>

        <xsl:if test="$herstellendeRollenN 
			or $herstellendeKollektiveN 
			or $herstellendeOrteN 
			or $herstellendeDatenTypenN">
			<lido:eventSet>
				<lido:displayEvent xml:lang="de">Herstellung</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00007</lido:conceptID>
						<lido:term xml:lang="de">Herstellung</lido:term>
						<lido:term xml:lang="en">Production</lido:term>
					</lido:eventType>

					<xsl:apply-templates select="$herstellendeRollenN"/>

					<!-- Ethnien und andere Kollektive aus GeoBezug-->
					<xsl:apply-templates mode="eventActor" select="$herstellendeKollektiveN"/>

					<!-- eventDate 

					SPEC allows repeated displayDates only for language variants; 
					according to spec event dates cannot be repeated. 
					
					BUT: AKu says it often has multiple dates representing multiple
					estimates.
					
					We can just take the one with the lowest sort order.

					TODO: Datierung engl.
					-->
					<xsl:for-each select="$herstellendeDatenTypenN[1]">
						<xsl:sort select="z:dataField/@name='SortLnu'" data-type="number" order="ascending"/>
						<xsl:variable name="dateType" select="z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/@name"/>
						<!--xsl:message>
							<xsl:text>dateType: </xsl:text>
							<xsl:value-of select="$dateType"/>
						</xsl:message-->
						<lido:eventDate>
							<xsl:apply-templates select="."/>
						</lido:eventDate>
					</xsl:for-each>
					
					<!-- eventPlace -->
					<xsl:apply-templates mode="eventPlace" select="$herstellendeOrteN"/>
					
					<!-- eventMaterialsTech; 
						at the moment Herstellung is the only eventType with materialTech; may change in future 
					-->
					<xsl:apply-templates select="z:repeatableGroup[@name = 'ObjMaterialTechniqueGrp' 
						and z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe']"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
	</xsl:template>
				
	<!-- 
		m3: Kultur auf Actor gemappt entsprechend Vorschlag FvH; 
		ich sehe bei unseren Daten im Moment keinen Vorteil gegenüber 
		lido: culture element, ist aber auch nicht falsch. Beide Stellen zu 
		nehmen, wäre vielleicht auch nicht schlecht, um unterschiedliche 
		Kunden zu bedienen.
		 and z:vocabularyReferenceItem/@name ='Ethnie'
		 
		actorInRole Spec 1.0:
		May include name, brief biographical information, and roles (if
		necessary) of the named actor, presented in a syntax suitable for
		display to the end-user and including any necessary indications
		of uncertainty, ambiguity, and nuance. If there is no known actor,
		make a reference to the presumed culture or nationality of the
		unknown actor.
		May be concatenated from the respective Actor element. The
		name should be in natural order, if possible, although inverted
		order is acceptable. Include nationality and life dates. For
		unknown actors, use e.g.: "unknown," "unknown Chinese,"
		"Chinese," or "unknown 15th century Chinese."
		Repeat this element only for language variants.
	-->
	<xsl:template mode="eventActor" match="z:repeatableGroup[
		@name = 'ObjGeograficGrp']/z:repeatableGroupItem[
		z:vocabularyReference/@name = 'GeopolVoc'  
	]">
		<lido:eventActor>
			<lido:displayActorInRole>
				<xsl:value-of select="z:vocabularyReference[@name = 'PlaceVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:text> (Herstellende </xsl:text>
				<xsl:value-of select="z:vocabularyReference [@name = 'GeopolVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:text>)</xsl:text>
			</lido:displayActorInRole>
			<lido:actorInRole>
				<lido:actor lido:type="group of persons">
					<lido:nameActorSet>
						<lido:appellationValue lido:pref="preferred">
							<xsl:value-of select="z:vocabularyReference[@name = 'PlaceVoc']/z:vocabularyReferenceItem/@name"/>
						</lido:appellationValue>
					</lido:nameActorSet>
				</lido:actor>
				<lido:roleActor>
					<lido:term lido:addedSearchTerm="no">
						<xsl:text>Herstellende </xsl:text>
						<xsl:value-of select="z:vocabularyReference [@name = 'GeopolVoc']/z:vocabularyReferenceItem/@name"/>
					</lido:term>
				</lido:roleActor>
			</lido:actorInRole>
		</lido:eventActor>
	</xsl:template>
		
	<!-- eventMaterialsTech -->
	<xsl:template mode="notUsedATM" match="
		z:repeatableGroup[
			@name = 'ObjMaterialTechniqueGrp' 
			and z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe'
		]">
		<lido:eventMaterialsTech>
			<xsl:apply-templates select="
				z:repeatableGroupItem[
					z:vocabularyReference/@name = 'TypeVoc' and 
					z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe'
				]"/>
		</lido:eventMaterialsTech>
	</xsl:template>

	<xsl:template match="
		z:repeatableGroup[
			@name = 'ObjMaterialTechniqueGrp' 
			and z:repeatableGroupItem/z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe'
		]">
		<lido:eventMaterialsTech>
			<lido:displayMaterialsTech xml:lang="de"> 
				<xsl:value-of select="z:dataField[@name = 'ExportClb']"/>
			</lido:displayMaterialsTech>
		</lido:eventMaterialsTech>
	</xsl:template>	

	<!-- not used at the moment-->
	<xsl:template match="z:vocabularyReference[@name = 'MaterialVoc']">
		<lido:termMaterialsTech lido:type="Material">
			<lido:term>
				<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
			</lido:term>
		</lido:termMaterialsTech>
	</xsl:template>
</xsl:stylesheet>