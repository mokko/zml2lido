<xsl:stylesheet version="2.0"
	xmlns:func="http://func"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:import href="event-Aufführung.xsl" />
    <xsl:import href="event-Auftrag.xsl" />
    <xsl:import href="event-Ausgrabung.xsl" />
    <xsl:import href="event-Benin.xsl" />
    <xsl:import href="event-Entwurf.xsl" />
    <xsl:import href="event-Erwerb.xsl" />
    <xsl:import href="event-Fund.xsl" />
    <!--xsl:import href="event-geistigeSchöpfung.xsl" /-->
    <xsl:import href="event-Herstellung.xsl"/>
    <xsl:import href="event-Sammeln.xsl" />
    <xsl:import href="event-Veröffentlichung.xsl" />
    <xsl:import href="event-unknown.xsl" />

	<!-- 
		http://terminology-view.lido-schema.org/vocnet/?startNode=lido00409&lang=en&uriVocItem=http://terminology.lido-schema.org/lido00228
		neue Events 
			
			Es gibt eine Rolle namens "Expedition" in MDS. Bis auf Weiteres Expedition nicht als EventType.
			Unknown event für alle nicht zugeordnete Rollen
	-->


    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <xsl:template name="eventWrap">
        <lido:eventWrap>
            <xsl:call-template name="Aufführung"/>			
			<xsl:call-template name="Auftrag"/>
			<xsl:call-template name="Ausgrabung"/>
			<xsl:call-template name="Benin"/>
			<xsl:call-template name="Entwurf"/>
			<xsl:call-template name="Erwerb"/>
			<xsl:call-template name="Fund"/>
			<!--xsl:call-template name="geistigeSchöpfung"/-->
            <xsl:call-template name="Herstellung"/>			
            <xsl:call-template name="Sammeln"/>
            <xsl:call-template name="Veröffentlichung"/>			
            <!--xsl:call-template name="unknown"/ doesn't work yet-->			
        </lido:eventWrap>
    </xsl:template>
	
	<!-- 
		The following template was written for Herstellung originally. Now I would like 
		to re-use it for all events which have an eventActor ?
	-->
	<xsl:template match="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem">
		<xsl:variable name="kueId" select="@moduleItemId"/>
		<xsl:variable name="kue" select="/z:application/z:modules/z:module[@name = 'Person']/z:moduleItem[@id = $kueId]"/>
		<xsl:variable name="gnd" select="$kue/z:repeatableGroup[@name = 'PerStandardDataGrp']/z:repeatableGroupItem/z:dataField[@name='GNDTxt']/z:value"/>
		<xsl:variable name="ulan" select="$kue/z:repeatableGroup[@name = 'PerStandardDataGrp']/z:repeatableGroupItem/z:dataField[@name='ULANTxt']/z:value"/>
		
		<!--xsl:message>
			<xsl:text>PK in Event: </xsl:text>
			<xsl:value-of select="z:formattedValue"/>
			<xsl:value-of select="$gnd"/>
		</xsl:message-->
		<lido:eventActor>
			<lido:displayActorInRole>
				<!-- vor event beschreibung aus RIA herausfiltern, z.B. "Herstellung: "-->
				<xsl:value-of select="normalize-space(substring-after(z:formattedValue, ': '))"/>
			</lido:displayActorInRole>
			<lido:actorInRole>
				<!-- http://xtree-public.digicult-verbund.de/vocnet/?uriVocItem=http://terminology.lido-schema.org/&startNode=lido00409&lang=en&d=n -->
				<lido:actor>
					<xsl:attribute name="lido:type" select="$kue/z:vocabularyReference[@name = 'PerTypeVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
					<lido:actorID lido:type="local" lido:source="RIA/SMB">
						<xsl:value-of select="$kueId"/>
					</lido:actorID>
					<xsl:if test="$gnd">
						<lido:actorID lido:type="URI" lido:source="GND">
							<xsl:value-of select="$gnd"/>
						</lido:actorID>
					</xsl:if>
					<xsl:if test="$ulan">
						<lido:actorID lido:type="URI" lido:source="ULAN">
							<xsl:value-of select="$ulan"/>
						</lido:actorID>
					</xsl:if>
					<lido:nameActorSet>
						<lido:appellationValue lido:pref="preferred">
							<xsl:value-of select="$kue/z:dataField[@name = 'PerNennformTxt']"/>
						</lido:appellationValue>
					</lido:nameActorSet>
					<lido:nationalityActor>
						<lido:term>
							<xsl:value-of select="$kue/z:vocabularyReference[@name = 'PerNationalityVoc']
							/z:vocabularyReferenceItem/z:formattedValue"/>
						</lido:term>
					</lido:nationalityActor>

					<!-- 
						LIDO 1.0 appears to be missing a mechanism to provide other dates than vitalDates 
						for an actor. Also missing is a displayDate to allow inexact textual info
						Please add that in a new version of the spec.
						
						It's possible to have multiple sets of Lebensdaten in RIA, e.g. kueId 387655
						Let's just take the first for now.
						
						RIA allows entry of non-numeric freely-formated values such as 
							<value>? - nach 1960</value>
						but LIDO strictly requires two values (from, to)
					-->
					<xsl:variable name="lebensdatenN" select="$kue/z:repeatableGroup[@name = 'PerDateGrp']
						/z:repeatableGroupItem[
							z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Lebensdaten'
						][1]"/>
					<xsl:variable name="dateFromTxt" select="$lebensdatenN/z:dataField[@name = 'DateFromTxt']/z:value"/>
					<xsl:variable name="dateToTxt" select="$lebensdatenN/z:dataField[@name = 'DateToTxt']/z:value"/>
					<xsl:if test="$dateFromTxt ne '' or $dateToTxt ne ''">
						<lido:vitalDatesActor>
							<xsl:if test="$dateFromTxt ne ''">
								<lido:earliestDate>
									<xsl:value-of select="func:reformatDate($dateFromTxt)"/>
								</lido:earliestDate>
							</xsl:if>
							<xsl:if test="$dateToTxt ne ''">
								<lido:latestDate>
									<xsl:value-of select="func:reformatDate($dateToTxt)"/>
								</lido:latestDate>
							</xsl:if>
							<!-- used to be 
								z:virtualField[@name = 'PreviewVrt']/z:value
								<xsl:value-of select="$lebensdatenN/z:dataField[@name = 'DatingNewTxt']/z:value"/>
							-->
						</lido:vitalDatesActor>
					</xsl:if>
					<lido:genderActor xml:lang="en">
						<xsl:value-of select="$kue/z:vocabularyReference[@name = 'PerGenderVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
					</lido:genderActor>
				</lido:actor>
				<lido:roleActor>
					<lido:term xml:lang="de" lido:encodinganalog="RIA:Rolle">
						<xsl:value-of select="z:vocabularyReference[@name = 'RoleVoc']/z:vocabularyReferenceItem/z:formattedValue"/> 
					</lido:term>
				</lido:roleActor>
				<lido:attributionQualifierActor xml:lang="de">
					<xsl:value-of select="z:vocabularyReference[@name = 'AttributionVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:attributionQualifierActor>
			</lido:actorInRole>
		</lido:eventActor>
	</xsl:template>


	<!-- 
	eventPlace
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

	<!-- not used at the moment -->
	<xsl:template mode="geoPol" match="z:vocabularyReference[
					@name = 'GeopolVoc']/z:vocabularyReferenceItem/@name">			
		<xsl:variable name="geographicEntities" select="
			'Atoll', 'Bach', 'Bach/Zufluss', 'Berg', 'Bucht', 'Bucht (Bay)', 'Fluss', 'Fluss, Bucht und Dorf',
			'Fluss/Gebiet', 'Flussmündung', 'Gebirge', 'Hafen', 'Halbinsel', 'Höhle', 'Insel', 'Insel/Region',
			'Inselgruppe', 'Kap', 'Kap (Cap/Point)', 'Kontinent', 'Kontintentteil', 'Küste', 'Landschaft',
			'Meerenge', 'Nebenfluss', 'See', 'See/Gebiet', 'Tal'"/>
		<xsl:variable name="politicalEntities" select="'Bezirk', 'Bezirk oder Stadt', 'Bundesstaat', 'Dorf', 
			'Großregion', 'Königreich', 'Land', 'Ort', 'Ort/Gebiet', 'Provinz', 'Sultanat', 'Stadt', 'Station'"/> 
		<xsl:variable name="undecided" select="'Gebiet', 'Hafen (Port)', 'Land/Region', 'Kloster', 
			'Kolonie/&quot;Schutzgebiet&quot;', 'Kultur/Ort', 'Region', 'Region oder Ort', 'Stadt/Umgebung',
			'Tempel'"/>
		<xsl:choose>
			<xsl:when test=". = $geographicEntities">
				<xsl:attribute name="lido:geographicalEntity">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = $politicalEntities">
				<xsl:attribute name="lido:politicalEntity">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:when>
			<!-- undecided: output geoname, but without type -->
			<xsl:when test=". = $undecided">
				<xsl:value-of select="."/>
			</xsl:when>
			<!-- dont output geoname at all -->
			<xsl:when test=". = 'Bevölkerungsgruppe'"/>

			<!-- Die with error message -->
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>Unknown geoPol type: </xsl:text>
					<xsl:value-of select="."/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>			
	
	<!-- eventDate -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjDateGrp']/z:repeatableGroupItem">
		<!-- 
			This should get called on every entry of Wiederholfeld. If any one of them
			is empty, it dies.
		
			It's possible, even likely, that for a given ObjDateGrp DateTxt is empty. 
			For the time being, let's not try to be 
			smarter than RIA and take a virtual Vorschau field (PreviewTxt). 
			
			In the RIA-interface this qualifier is called "Typ"; i call it "dateType".
			Schreibanweisung says: no type equals "Herstellung"		
			common values:
				Datierung engl.
				Herstellung
				Aufnahme
				Epoche des Originals
				Aufnahmejahr: seems to be a bad value, should be Aufnahme
		-->
		<xsl:variable name="displayDate">
			<xsl:choose>
				<xsl:when test="z:dataField[@name = 'PreviewTxt']/z:value ne ''">
					<xsl:value-of select="z:dataField[@name = 'PreviewTxt']/z:value"/>
				</xsl:when>
				<xsl:when test="z:virtualField[@name = 'PreviewVrt']/z:value ne ''">
					<xsl:value-of select="z:virtualField[@name = 'PreviewVrt']/z:value"/>
				</xsl:when>
				<xsl:when test="z:dataField[@name = 'NotesClb']/z:value ne ''">
					<xsl:value-of select="z:dataField[@name = 'NotesClb']/z:value"/>
				</xsl:when>
				
				<xsl:otherwise>
					<xsl:message terminate="no">
						<xsl:text>INFO: No displayDate </xsl:text>
						<xsl:value-of select="../../../@name"/>
						<xsl:text>: </xsl:text>
						<xsl:value-of select="../../@id"/>
					</xsl:message>
					<!--
					If this fails ObjDateGrp exists, but no entry in the fields above;
					it is no error if displayDate is empty.
					-->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$displayDate ne ''">
			<lido:displayDate xml:lang="de">
				<xsl:value-of select="$displayDate"/>
			</lido:displayDate>
		</xsl:if>
		<xsl:if test="z:dataField[@name = 'DateFromTxt'] ne '' or z:dataField[@name = 'DateToTxt'] ne ''">
			<lido:date>
				<xsl:if test="z:dataField[@name = 'DateFromTxt'] ne ''">
					<lido:earliestDate>
						<xsl:value-of select="func:reformatDate(z:dataField[@name = 'DateFromTxt'])"/>
					</lido:earliestDate>
				</xsl:if>
				<xsl:if test="z:dataField[@name = 'DateToTxt'] ne ''">
					<lido:latestDate>
						<xsl:value-of select="func:reformatDate(z:dataField[@name = 'DateToTxt'])"/>
					</lido:latestDate>
				</xsl:if>
			</lido:date>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>