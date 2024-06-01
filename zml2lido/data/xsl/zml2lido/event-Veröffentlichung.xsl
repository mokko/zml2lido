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
		Veröffenlichung: 'Produzent',
    -->
    <xsl:template name="Veröffentlichung">
		<xsl:variable name="veröffentlichendeRollen" select="'Produzent', 'Produzent*in'"/>
		<xsl:variable name="perInRole" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $veröffentlichendeRollen]"/>

        <xsl:if test="$perInRole">
			<lido:eventSet lido:sortorder="10">
				<lido:displayEvent xml:lang="de">Veröffentlichung</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00228</lido:conceptID>
						<lido:term xml:lang="en">Publication</lido:term>
						<lido:term xml:lang="de">Veröffentlichung (Ereignis)</lido:term>
					</lido:eventType>
					<xsl:apply-templates select="$perInRole"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>