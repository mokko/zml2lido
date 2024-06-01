<xsl:stylesheet version="2.0"
	xmlns:func="http://func"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
		Zuordnung zu einem kuratierten Bestand
    -->
    <xsl:template name="Zuordnung">
		<xsl:variable name="bereich" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:variable name="sammlung" select="func:vocmap-control('Bereich',$bereich)"/>

		<lido:eventSet lido:sortOrder="30">
			<lido:event>
				<lido:eventType>
					<lido:conceptID lido:source="LIDO-Terminologie"
						lido:type="http://terminology.lido-schema.org/lido00099">http://terminology.lido-schema.org/lido01146</lido:conceptID>
					<lido:term lido:label="Assignment to a curated holding"
						lido:addedSearchTerm="no">Zuordnung zu einem kuratierten Bestand</lido:term>
				</lido:eventType>
				<lido:thingPresent>
					<lido:displayObject>
						<xsl:value-of select="$sammlung"/>
					</lido:displayObject>
				</lido:thingPresent>
			</lido:event>
		</lido:eventSet>
    </xsl:template>
</xsl:stylesheet>


