<xsl:stylesheet version="2.0"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	exclude-result-prefixes="z"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template name="Herstellung">
		<xsl:variable name="herstellendeRollen" select="
			'Absender', 'Absenderin', 'Absender*in',
			'Autor', 'Autorin','Autor*in',
			'Bildhauer', 'Bildhauerin', 'Bildhauer*in',
			'Drucker', 'Drucker*in',
			'Empfänger', 'Empfängerin','Empfänger*in',
			'Filmemacher', 'Filmemacher*in',
			'Filmregisseur', 'Filmregisseur*in',
			'Fotograf', 'Fotograf*in',
			'Hersteller', 'Hersteller*in',
			'Inventor', 
			'Künstler', 'Künstlerin','Künstler des Originals', 'Künstler*in', 
			'Maler', 'Malerin',	'Maler*in',	
			'Stecher', 'Stecherin', 'Stecher*in',
			'Zeichner', 'Zeichnerin', 'Zeichner*in'"/>
			
		<xsl:variable name="herstellendeKollektive" select="
			'Ethnie',
			'Kultur',
			'Sprachgruppe'"/>

		<xsl:variable name="herstellendeOrtstypen" select="
			'Aufnahmeort',
			'dargestellter Ort',
			'Druckort',
			'Entstehungsort',
			'Entstehungsort stilistisch',
			'faktischer Entstehungsort',
			'Herstellungsort'"/>
		
		<xsl:variable name="herstellendeRollenN" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $herstellendeRollen]"/>

		<xsl:variable name="herstellendeKollektiveN" select="
			z:repeatableGroup[
				@name = 'ObjGeograficGrp']/
			z:repeatableGroupItem[
				z:vocabularyReference/@name = 'GeopolVoc' 
				and z:vocabularyReferenceItem/@name = $herstellendeKollektive
			]"/>

		<!-- 
		old version selected
			z:repeatableGroup[@name = 'ObjGeograficGrp']
		but now I expect 
			z:repeatableGroup[@name = 'ObjGeograficGrp']/z:repeatableGroupItem

		Old version did that to have access to all geonames in one place. That was a solution specific for EM's 
		geoname chains
		-->
		<xsl:variable name="herstellendeOrteNN" select="
			z:repeatableGroup[
				@name = 'ObjGeograficGrp'
			]/z:repeatableGroupItem[
				z:vocabularyReference[
					@name = 'TypeVoc' 
				]/z:vocabularyReferenceItem[
					@name = $herstellendeOrtstypen
				] or not(z:vocabularyReference[
					@name = 'TypeVoc' 
				])
			]"/>


		<!-- "Aufnahmejahr" should be "Aufnahme" etc., but it will exist for some time -->
		<xsl:variable name="herstellendeDatenTypen" select="
			'Aufnahme',
			'Aufnahmejahr', 
			'Herstellung',
			'Publik. Jahr'
		"/>

		<xsl:variable name="herstellendeDatenTypenN" select="
			z:repeatableGroup[
				@name = 'ObjDateGrp']/
			z:repeatableGroupItem[
				z:vocabularyReference[@name = 'TypeVoc']/
				z:vocabularyReferenceItem/@name = $herstellendeDatenTypen
				or not (z:vocabularyReference[@name = 'TypeVoc'])
		]"/>

        <xsl:if test="$herstellendeRollenN 
			or $herstellendeKollektiveN 
			or $herstellendeOrteNN 
			or $herstellendeDatenTypenN
			or z:repeatableGroup[@name = 'ObjMaterialTechniqueGrp']
		">
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
					
					<!-- 
					eventPlace 
					
					We used to call eventPlace once for all places, now we call eventPlace once for every place,
					hence we need to sort each place now
					-->	
					<xsl:apply-templates mode="eventPlace" select="$herstellendeOrteNN">
						<xsl:sort select="z:dataField[@name='SortLnu']" data-type="number" order="ascending"/>
					</xsl:apply-templates>
					
					<!--  
						at the moment Herstellung is the only eventType with materialTech 
					-->
					<xsl:variable name="ausgabeQualis" select="'Ausgabe', 'Ausgabe (engl.)'"/>
					<xsl:for-each select="z:repeatableGroup[@name = 'ObjMaterialTechniqueGrp']">
						<lido:eventMaterialsTech>
							<xsl:apply-templates mode="ausgabe" select="
								z:repeatableGroupItem[
									z:vocabularyReference[
										@name='TypeVoc'
									]/z:vocabularyReferenceItem[
										@name = $ausgabeQualis
									]
								]"/>

							<xsl:variable name="notAusgabeN" select="
								z:repeatableGroupItem[
									z:vocabularyReference[
										@name='TypeVoc'
									]/z:vocabularyReferenceItem[
										not (@name = $ausgabeQualis)
									]
								]
							"/>
							
							<!--
							19.5.2023 Einträge in RIA sind nicht gut. Lieber nicht so anzeigen.
							-->
							<xsl:if test="$notAusgabeN">
								<lido:materialsTech>
									<xsl:for-each select="$notAusgabeN">
										<xsl:apply-templates mode="nichtAusgabe" select="
											z:vocabularyReference[@name='TypeVoc']
										"/>
									</xsl:for-each>
								</lido:materialsTech>
							</xsl:if>
						</lido:eventMaterialsTech>
					</xsl:for-each>
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

		z:repeatableGroup[
			@name = 'ObjGeograficGrp']/
		z:repeatableGroupItem/z:vocabularyReference[
			@name = 'GeopolVoc' 
			and z:vocabularyReferenceItem/@name = $herstellendeKollektive

	-->
	<xsl:template mode="eventActor" match="z:repeatableGroup[
		@name = 'ObjGeograficGrp']/z:repeatableGroupItem">
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
		
	<xsl:template mode="ausgabe" match="						
		z:repeatableGroupItem[
			z:vocabularyReference[
				@name='TypeVoc'
			]/z:vocabularyReferenceItem
		]">
		<lido:displayMaterialsTech>
			<xsl:attribute name="xml:lang">
				<xsl:choose>
					<xsl:when test="z:vocabularyReference[@name='TypeVoc']/z:vocabularyReferenceItem[@name = 'Ausgabe (engl.)']">
						<xsl:text>en</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>de</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="normalize-space(z:dataField[@name = 'ExportClb']/z:value)"/>
		</lido:displayMaterialsTech>
	</xsl:template>

	<xsl:template mode="nichtAusgabe" match="z:vocabularyReference[@name='TypeVoc']">
		<xsl:variable name="ignore" select="'Farbe'"/>
		<xsl:if test="z:vocabularyReferenceItem/@name != $ignore">
			<xsl:variable name="matVoc" select="
				../z:vocabularyReference[
					@name = 'MaterialVoc' or
					@name = 'EgyptVoc'
				]/z:vocabularyReferenceItem"/>
			<xsl:variable name="matTech" select="
				replace(
					$matVoc/z:formattedValue, 
					'^;+(\w*)',
					'$1'
				)"/>
			
			<xsl:variable name="type" select="z:vocabularyReferenceItem/@name"/>
			
			<lido:termMaterialsTech>
				<xsl:attribute name="lido:type">
					<xsl:choose>
						<xsl:when test="$type eq 'Material' or $type eq 'Material (engl.)'">
							<xsl:text>http://terminology.lido-schema.org/lido00132</xsl:text>
						</xsl:when>

						<xsl:when test="$type eq 'Technik' or $type eq 'Technik (engl.)'">
							<xsl:term xml:lang="en">
								<xsl:text>http://terminology.lido-schema.org/lido00131</xsl:text>
							</xsl:term>
						</xsl:when>
						<!-- neu 5.12.22 SBM -->
						<xsl:when test="$type eq 'Auflage'"/>
						<!-- neu 3.5.22 Frühe Plakate Beschreibung der Technik und Präsentationsform -->
						<xsl:when test="$type eq 'Bemalung/Farbe'"/>
						<xsl:when test="$type eq 'Beschreibung der Technik'"/>
						<xsl:when test="$type eq 'Datum'"/>
						
						<xsl:when test="$type eq 'Herstellungsart'"/>
						<xsl:when test="$type eq 'Herstellungstechnik'"/>						
						<!-- neu 3.5.22 Fotografisches Verfahren in Berlin Zeichnet Mode-->
						<xsl:when test="$type eq 'Fotografisches Verfahren'"/>						
						<xsl:when test="$type eq 'Kontrollnummer'"/>
						<xsl:when test="$type eq 'Material des Originals'"/>
						<xsl:when test="$type eq 'Materialfarbe'"/>
						<xsl:when test="$type eq 'Material/Technik (Rest.)'"/>
						<xsl:when test="$type eq 'Material/Werkstoff'"/>
						<xsl:when test="$type eq 'Nominal'"/>
						<xsl:when test="$type eq 'Oberfläche'"/>
						<xsl:when test="$type eq 'Präsentationsform'"/>
						<xsl:when test="$type eq 'Rahmen'"/>
						<xsl:when test="$type eq 'Reliefhöhe'"/>						
						<xsl:when test="$type eq 'Stempelstellung'"/>
						<xsl:when test="$type eq 'Wasserzeichen'"/>						

						<xsl:otherwise>
							<xsl:message terminate="yes">
								<xsl:text>ERROR: Unknown material type! </xsl:text>
								<xsl:value-of select="normalize-space(z:vocabularyReferenceItem/@name)"/>
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<lido:conceptID lido:source="../z:vocabularyReference[1]/@name" lido:type="local">
					<xsl:value-of select="$matVoc/@id"/>
				</lido:conceptID>
				<lido:term xml:lang="de">
					<xsl:attribute name="xml:lang">
						<xsl:choose>
							<xsl:when test="$type eq 'Material (engl.)'">
								<xsl:text>en</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>de</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:value-of select="normalize-space($matTech)"/>
				</lido:term>
			</lido:termMaterialsTech>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>