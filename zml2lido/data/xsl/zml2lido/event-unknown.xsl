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
		unknownEvent: alle Rollen, die wir noch nicht berücksichtigt haben
		Vorbesitzer, Veräußerer: werden nicht bei unknownEvent angezeigt
    -->
    <xsl:template name="unknown">
		<xsl:variable name="zugeordnet" select="
			'Auftraggeber',
			'Autor',
			'Bildhauer', 'Bildhauerin', 
			'Darsteller', 'Darstellerin', 
			'Designer',
			'Dirigent', 'Dirigentin', 
			'Entwerfer', 
			'Filmemacher', 
			'Filmregisseur', 
			'Finder', 
			'Fotograf', 
			'Grabungsleiter',
			'Interpret', 'Interpretin',
			'Inventor', 
			'Künstler', 'Künstlerin','Künstler des Originals',  
			'Maler', 'Malerin',		
			'Münzherr',
			'Produzent',
			'Sammler', 'Sammlerin',
			'Veräußerer',
			'Vorbesitzer',
			'Zeichner', 'Zeichnerin'
		"/>
		<xsl:variable name="nichtZugeordnet" select="z:moduleReference[
			@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $zugeordnet]"/>
        <xsl:if test="$nichtZugeordnet">
			<lido:eventSet>
				<lido:displayEvent xml:lang="de">Unbekanntes Ereignis</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00003</lido:conceptID>
						<lido:term xml:lang="en">Unknown event</lido:term>
						<lido:term xml:lang="de">Unbekanntes Ereignis</lido:term>
					</lido:eventType>
					<xsl:message>
						<xsl:text>UNKNOWN UNKNOWN UNKNOWN</xsl:text>
					</xsl:message>
					<xsl:apply-templates select="$nichtZugeordnet"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>