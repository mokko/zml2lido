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
		Erwerb is an unusual event; it's fed only by RIA:ErwerbNotizAusgabe which may
		contain (unstructured) information on when, who etc.

		
		DF from http://terminology-view.lido-schema.org/vocnet
		Acquisition, as a value for the LIDO Event Type element, designates the physical and legal 
		transfer of items to a repository, such as a museum, library, or archive, including the 
		selection, ordering, and obtaining by purchase, gift, or exchange.
		
        Apparently some records with a Sammler dont have the Sammeln-event? 
        Why because i wrote eq Sammler instead of = Sammler.
        Let that be a lesson!
		
		Todo: Erwerbungsort 
    -->

    <xsl:template name="Erwerb">
		<xsl:if test="z:repeatableGroup[
			@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
			z:vocabularyReference/z:vocabularyReferenceItem/@name='Ausgabe']">
			<lido:eventSet>
				<lido:displayEvent xml:lang="de">Erwerb</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00001</lido:conceptID>
						<lido:term xml:lang="de">Erwerb</lido:term>
						<xsl:comment>beschreibt den Erwerb des Objekts durch die verwaltende Institution</xsl:comment>
					</lido:eventType>

					<!-- lido:eventActor 
					<xsl:apply-templates select="z:repeatableGroup[@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
						z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Erwerbung von']"/>
					-->

					<!-- todo xsl:apply-templates mode="Erwerb" select="personenKörperschaften[@funktion eq 'Veräußerer']"/-->

					<!-- lido:eventDate; call only when it has a date 
					<xsl:apply-templates select="z:repeatableGroup[@name = 'ObjAcquisitionDateGrp']/z:repeatableGroupItem[
						z:dataField/@name='DateFromTxt']"/>
					-->

					<!-- lido:eventMethod (m3: neuer Platz für Erwerbungsart nach Empfehlung FvH) 
					<xsl:apply-templates select="z:repeatableGroup[@name = 'ObjAcquisitionMethodGrp']/z:repeatableGroupItem"/>
					-->
					
					<!-- eventDescriptionSet ErwerbNotizAusgabe-->
					<xsl:apply-templates mode="Erwerb" select="z:repeatableGroup[
						@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
						z:vocabularyReference/z:vocabularyReferenceItem/@name='Ausgabe']"/>
				</lido:event>
			</lido:eventSet>
        </xsl:if>
    </xsl:template>

	<xsl:template mode="Erwerb" match="z:repeatableGroup[
		@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
		z:vocabularyReference/z:vocabularyReferenceItem/@name='Ausgabe'
	]">
		<lido:eventDescriptionSet> 
			<lido:descriptiveNoteValue xml:lang="de" lido:encodinganalog="ErwerbNotizAusgabe">
				<xsl:value-of select="z:dataField[@name = 'MemoClb']/z:value"/>
			</lido:descriptiveNoteValue>
		</lido:eventDescriptionSet>
	</xsl:template>


	<!-- eventActor: we're not using these at the moment, just ErwerbNotizAusgabe -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
		z:vocabularyReference/z:vocabularyReferenceItem/@name = 'Erwerbung von']">
		<lido:eventActor>
            <lido:displayActorInRole lido:encodinganalog="ObjAcquisitionNotesGrp">
                <xsl:value-of select="z:dataField[@name = 'MemoClb']/z:value"/>
                <xsl:text> (Veräußerer)</xsl:text>
            </lido:displayActorInRole>
            <lido:actorInRole>
                <lido:actor>
                    <!-- kein ID an dieser Stelle in M+ vorhanden (Register Erwerb); möglicherweise in RIA-->
                    <lido:nameActorSet>
                        <lido:appellationValue>
                            <xsl:value-of select="z:dataField[@name = 'MemoClb']/z:value"/>
                        </lido:appellationValue>
                    </lido:nameActorSet>
                </lido:actor>
                <lido:roleActor>
                    <lido:term xml:lang="de" lido:addedSearchTerm="no">Veräußerer</lido:term>
                    <lido:term xml:lang="en" lido:addedSearchTerm="no">seller</lido:term>
                </lido:roleActor>
            </lido:actorInRole>
        </lido:eventActor>	
	</xsl:template>

	<!-- eventDate: not in use -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjAcquisitionDateGrp']/z:repeatableGroupItem">
 		<lido:eventDate>
            <lido:displayDate>
                <xsl:value-of select="z:dataField[@name='DateFromTxt']"/>
            </lido:displayDate>
            <lido:date>
                <lido:earliestDate>
                    <xsl:value-of select="z:dataField[@name='DateFromTxt']"/>
                </lido:earliestDate>
                <lido:latestDate>
                    <xsl:value-of select="z:dataField[@name='DateFromTxt']"/>
                </lido:latestDate>
            </lido:date>
        </lido:eventDate>
	</xsl:template>


	<!-- eventMethod: not in use -->
	<xsl:template match="z:repeatableGroup[@name = 'ObjAcquisitionMethodGrp']/z:repeatableGroupItem">
		<lido:eventMethod>
		     <lido:term xml:lang="de">
		     	<xsl:value-of select="z:vocabularyReference[@name ='MethodVoc']/z:vocabularyReferenceItem/@name"/>
		     </lido:term>
		     <!-- xsl:if test="$translation"> TODO
		         <lido:term xml:lang="en">
		             <xsl:value-of select="$translation"/>
		         </lido:term>
		     </xsl:if -->
		 </lido:eventMethod>
	</xsl:template>
</xsl:stylesheet>