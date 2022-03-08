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
	1.1 repositorySet
	A wrapper containing identification and designation of the institution of custody
	and, possibly, indication of the exact location of the object. Repeated
	if there are several designations known, or if former repositories should be
	listed. 
	-->

	<xsl:template name="repositoryWrap">
        <lido:repositoryWrap>
        	<lido:repositorySet lido:type="current">
				<lido:repositoryName>
					<xsl:call-template name="legalBody">
						<xsl:with-param name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
					</xsl:call-template>
				</lido:repositoryName>
	        	<xsl:apply-templates select="z:moduleReference[@name='ObjOwnerRef']"/>
	        	<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectNumberGrp']/z:repeatableGroupItem"/>
		        <!-- Berlin repository location -->
				<lido:repositoryLocation lido:politicalEntity="inhabited place">
		          <lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7003712</lido:placeID>
		          <lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2950159</lido:placeID>
		          <lido:namePlaceSet>
		             <lido:appellationValue>Berlin</lido:appellationValue>
		          </lido:namePlaceSet>
		          <lido:partOfPlace lido:politicalEntity="State">
		             <lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7003670</lido:placeID>
		             <lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2950157</lido:placeID>
		             <lido:namePlaceSet>
		                <lido:appellationValue>Berlin</lido:appellationValue>
		             </lido:namePlaceSet>
		             <lido:partOfPlace lido:politicalEntity="nation">
		                <lido:placeID lido:type="URI" lido:source="http://vocab.getty.edu/tgn/">http://vocab.getty.edu/tgn/7000084</lido:placeID>
		                <lido:placeID lido:type="URI" lido:source="http://sws.geonames.org/">http://sws.geonames.org/2921044</lido:placeID>
		                <lido:namePlaceSet>
		                   <lido:appellationValue>Deutschland</lido:appellationValue>
		                </lido:namePlaceSet>
		             </lido:partOfPlace>
		          </lido:partOfPlace>
		          </lido:repositoryLocation>
	          </lido:repositorySet>
		</lido:repositoryWrap>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjObjectNumberGrp']/z:repeatableGroupItem">
		<!-- 
			20220211 war InventarNrSTxt; komischer Fehler bei Marie Schulz 
					Konvolut-Nr statt IdentNr; dann mit NumberVrt ersetzt. 
			20220307 Jetzt beide Felder plus Fehlermeldung, wenn identNr immer noch leer.
		-->
		<xsl:variable name="identNr">
			<xsl:choose>
				<xsl:when test="z:dataField[@name='NumberVrt']/z:value ne ''">
					<xsl:value-of select="z:dataField[@name='NumberVrt']/z:value"/>
				</xsl:when>
				<xsl:when test="z:dataField[@name='InventarNrSTxt']/z:value ne ''">
					<xsl:value-of select="z:dataField[@name='InventarNrSTxt']/z:value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">WARN: No identNr</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<lido:workID lido:type="Inventory number" lido:label="Ident.Nr.">
			<xsl:value-of select="$identNr"/>
		</lido:workID>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name='ObjOwnerRef']">
		<lido:repositoryName>	
	        <xsl:choose>
	        	<!-- The following values culd be taken from PK module, but at what cost... -->
	            <xsl:when test=". eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
	                <lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019118</lido:legalBodyID>
	                <lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019118</lido:legalBodyID>
	                <xsl:call-template name="legalBodyName"/>
	                <lido:legalBodyWeblink>http://www.smb.museum/em</lido:legalBodyWeblink>
	            </xsl:when>
	            <!-- verwaltendeInstiution AKu untested -->
	            <xsl:when test=". eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
	                <lido:legalBodyID lido:type="URI" lido:source="ISIL (ISO 15511)">http://www.museen-in-deutschland.de/singleview.php?muges=019014</lido:legalBodyID>
	                <lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019014</lido:legalBodyID>
	                <xsl:call-template name="legalBodyName"/>
	                <lido:legalBodyWeblink>http://www.smb.museum/aku</lido:legalBodyWeblink>
	            </xsl:when>
	            <xsl:when test=". eq 'Museum für Islamische Kunst, Staatliche Museen zu Berlin'">
					<!-- kann keine ISIL für das ISL finden -->
	                <xsl:call-template name="legalBodyName"/>
	                <lido:legalBodyWeblink>http://www.smb.museum/isl</lido:legalBodyWeblink>
	            </xsl:when>
	            <xsl:otherwise>
	                <xsl:message terminate="yes">
						<xsl:value-of select="."/>
	                    <xsl:text>Error: Unknown Institution</xsl:text>
	                </xsl:message>
	            </xsl:otherwise>
	        </xsl:choose>
        </lido:repositoryName>
	</xsl:template>

	<xsl:template name="legalBodyName">
        <lido:legalBodyName>
            <lido:appellationValue>
                <xsl:value-of select="." />
            </lido:appellationValue>
        </lido:legalBodyName>
    </xsl:template>
</xsl:stylesheet>