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
        <lido:eventSet>
            <lido:displayEvent xml:lang="de">Herstellung</lido:displayEvent>
            <lido:event>
                <lido:eventType>
                    <lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00007</lido:conceptID>
                    <lido:term xml:lang="de">Herstellung</lido:term>
                </lido:eventType>

				<!-- eventActor 
					Todo: There could be a PK@Hersteller 
				-->
                <xsl:apply-templates mode="eventActor" select="z:repeatableGroup[
                	@name = 'ObjGeograficGrp']/z:repeatableGroupItem[
                	z:vocabularyReference/@name = 'GeopolVoc' and 
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Ethnie' or
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Kultur' or
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Sprachgruppe' 
                	]"/>

                <!-- eventDate 

                SPEC allows repeated displayDates only for language variants; 
                according to spec event dates cannot be repeated. 
                
                BUT: AKu says it often has multiple dates representing multiple
                estimates.
				
				We can just take the one with the lowest sort order
	            -->

				<lido:eventDate>
					<xsl:apply-templates select="z:repeatableGroup[@name = 'ObjDateGrp']/z:repeatableGroupItem[1]">
						<xsl:sort select="z:dataField/@name='SortLnu'" data-type="number" order="ascending"/>
					</xsl:apply-templates>
				</lido:eventDate>
				
				<!-- 
				eventPlace 
				/z:repeatableGroupItem[
                	z:vocabularyReference/@name = 'GeopolVoc' and not(
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Ethnie' or
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Kultur' or
                	z:vocabularyReference/z:vocabularyReferenceItem/@name ='Sprachgruppe') 
                	]
				-->
				<xsl:apply-templates mode="eventPlace" select="z:repeatableGroup[@name = 'ObjGeograficGrp']"/>

				<!-- eventMaterialsTech -->
				<lido:eventMaterialsTech>
					<xsl:apply-templates select="z:repeatableGroup[
						@name = 'ObjMaterialTechniqueGrp']/z:repeatableGroupItem"/>
				</lido:eventMaterialsTech>
            </lido:event>
        </lido:eventSet>
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
		z:vocabularyReference/@name = 'GeopolVoc' and 
		z:vocabularyReference/z:vocabularyReferenceItem/@name ='Ethnie' or
		z:vocabularyReference/z:vocabularyReferenceItem/@name ='Kultur' or
		z:vocabularyReference/z:vocabularyReferenceItem/@name ='Sprachgruppe' 
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
        
	<!-- eventDate -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjDateGrp']/z:repeatableGroupItem">
            <lido:displayDate>
                <xsl:value-of select="z:dataField[@name = 'DateTxt']/z:value"/>
            </lido:displayDate>
            <xsl:if test="z:dataField[@name = 'DateFromTxt'] or z:dataField[@name = 'DateToTxt']">
                <lido:date>
                    <xsl:if test="z:dataField[@name = 'DateFromTxt']">
                        <lido:earliestDate>
                            <xsl:value-of select="z:dataField[@name = 'DateFromTxt']"/>
                        </lido:earliestDate>
                    </xsl:if>
                    <xsl:if test="z:dataField[@name = 'DateToTxt']">
                        <lido:latestDate>
                            <xsl:value-of select="z:dataField[@name = 'DateToTxt']"/>
                        </lido:latestDate>
                    </xsl:if>
                </lido:date>
            </xsl:if>
	</xsl:template>

	<!-- eventMaterialsTech -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjMaterialTechniqueGrp']/z:repeatableGroupItem">
			<xsl:apply-templates select=".[z:vocabularyReference/@name = 'TypeVoc' 
					and z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe']"/>
			<!--lido:materialsTech>
				<xsl:apply-templates select="z:vocabularyReference[@name = 'MaterialVoc']"/>
			</lido:materialsTech-->
    </xsl:template>	

	<xsl:template match=".[z:vocabularyReference/@name = 'TypeVoc' 
		and z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Ausgabe']">
		<lido:displayMaterialsTech xml:lang="de">
				<xsl:value-of select="z:dataField[@name = 'ExportClb']"/>
		</lido:displayMaterialsTech>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[@name = 'MaterialVoc']">
		<lido:termMaterialsTech lido:type="Material">
			<lido:term>
				<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
			</lido:term>
		</lido:termMaterialsTech>
	</xsl:template>
	

	<!-- eventPlace
		TODO: im Augenblick sind Kultur, Ethnie und Sprachgruppe nicht ausgeschlossen!
		TODO: Place
	-->
	<xsl:template mode="eventPlace" match="z:repeatableGroup[@name = 'ObjGeograficGrp']">
 		<lido:eventPlace>
            <lido:displayPlace xml:lang="de">
                <xsl:attribute name="lido:encodinganalog">PlaceVoc</xsl:attribute>
				<xsl:for-each select="z:repeatableGroupItem/z:vocabularyReference[@instanceName='GenPlaceVgr']">
					<xsl:sort select="dataField[@name='SortLnu']" data-type="number" order="ascending"/>
					<xsl:value-of select="replace(z:vocabularyReferenceItem/z:formattedValue, '^;(\w*)','$1')"/>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
            </lido:displayPlace>
        </lido:eventPlace>                	
	</xsl:template>

	<xsl:template mode="geoPol" match="z:vocabularyReference[
            		@name = 'GeopolVoc']/z:vocabularyReferenceItem/@name">	        
		<xsl:choose>
		    <!-- geographicEntities -->
		    <xsl:when test=". = 'Atoll'
		        or . = 'Bach'
		        or . = 'Bach/Zufluss'
		        or . = 'Berg'
		        or . = 'Bucht'
		        or . = 'Bucht (Bay)'
		        or . = 'Fluss'
		        or . = 'Fluss, Bucht und Dorf'
		        or . = 'Fluss/Gebiet'
		        or . = 'Flussmündung'
		        or . = 'Gebirge'
		        or . = 'Hafen'
		        or . = 'Halbinsel'
		        or . = 'Höhle'
		        or . = 'Insel'
		        or . = 'Insel/Region'
		        or . = 'Inselgruppe'
		        or . = 'Kap'
		        or . = 'Kap (Cap/Point)'
		        or . = 'Kontinent'
		        or . = 'Kontintentteil'
		        or . = 'Küste'
		        or . = 'Landschaft'
		        or . = 'Meerenge'
		        or . = 'Nebenfluss'
		        or . = 'See'
		        or . = 'See/Gebiet'
		        or . = 'Tal'">
		        <xsl:attribute name="lido:geographicalEntity">
		            <xsl:value-of select="."/>
		        </xsl:attribute>
		    </xsl:when>
		    <!-- politicalEntities -->
		    <xsl:when test=". = 'Bezirk'
		        or . = 'Bezirk oder Stadt'
				or . = 'Bundesstaat'
				or . = 'Dorf'
		    	or . = 'Großregion'
		    	or . = 'Königreich'
		    	or . = 'Land'
				or . = 'Ort'
				or . = 'Ort/Gebiet'
				or . = 'Provinz'
				or . = 'Sultanat'
		    	or . = 'Stadt'
		    	or . = 'Station'
			    ">
	            <xsl:attribute name="lido:politicalEntity">
	                <xsl:value-of select="."/>
	            </xsl:attribute>
		    </xsl:when>
			<!-- undecided: output geoname, but without type -->
		    <xsl:when test=". = 'Gebiet'
		    	or . = 'Hafen (Port)'
		    	or . = 'Land/Region'
				or . = 'Kloster'
				or . = 'Kolonie/&quot;Schutzgebiet&quot;'
				or . = 'Kultur/Ort'
		    	or . = 'Region'
				or . = 'Region oder Ort'
				or . = 'Stadt/Umgebung'
				or . = 'Tempel'
			    ">
			    <xsl:value-of select="."/>
		    </xsl:when>
			<!-- dont output geoname at all -->
			<xsl:when test=". = 'Bevölkerungsgruppe'"/>

			<!-- Die with message unknown type -->
		    <xsl:otherwise>
		    	<xsl:message terminate="yes">
		    		<xsl:text>Unknown geoPol type: </xsl:text>
					<xsl:value-of select="."/>
		    	</xsl:message>
		    </xsl:otherwise>
		</xsl:choose>
	</xsl:template>	        
</xsl:stylesheet>