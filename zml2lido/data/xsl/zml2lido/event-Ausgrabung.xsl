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
		Excarvation/Ausgrabung: Grabungsleiter
    -->
    <xsl:template name="Ausgrabung">
		<xsl:variable name="grabendeRollen" select="
			'Grabungsleiter', 'Grabungsleiter*in'"/>
		<xsl:variable name="perInRole" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $grabendeRollen]"/>
					
        <xsl:if test="$perInRole">
			<lido:eventSet lido:sortorder="10">
				<lido:displayEvent xml:lang="de">Ausgrabung</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00033</lido:conceptID>
						<lido:term xml:lang="en">Excavation</lido:term>
						<lido:term xml:lang="de">Ausgrabung</lido:term>
					</lido:eventType>
					<xsl:apply-templates select="$perInRole"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>