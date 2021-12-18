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
		Fund/Finding: , http://terminology.lido-schema.org/lido00002
		
		Todo: Fundort, Grabungsort, Fundort (Fundstelle), Fundquadrant
		-> Funddatum
    -->
    <xsl:template name="Fund">
		<xsl:variable name="findendeRollen" select="'Finder'"/>
		<xsl:variable name="findendeRollenN" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $findendeRollen]"/>

		<xsl:variable name="findendeOrtstypen" select="
			'Fundort',
			'Fundort modern',
			'Fundort detail',
			'Fundort (normiert)',
			'Fundquadrant',
			'Fundort (Fundstelle)',
			'Fundort des Originals',
			'Fundort (aktueller)',
			'Fundort (?)'
		"/>
		<xsl:variable name="findendeRollenN" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $findendeRollen]"/>

		<xsl:variable name="fundorteN" select="z:repeatableGroup[
			@name = 'ObjGeograficGrp' and 
			z:repeatableGroupItem/z:vocabularyReference[
				@name = 'TypeVoc' and 
				z:vocabularyReferenceItem/@name = $findendeOrtstypen
				]
			]"/>

        <xsl:if test="$findendeRollenN or $fundorteN">
			<lido:eventSet>
				<lido:displayEvent xml:lang="de">Fund (Aktivität)</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00002</lido:conceptID>
						<lido:term xml:lang="en">Finding (Activity)</lido:term>
						<lido:term xml:lang="de">Fund (Aktivität)</lido:term>
					</lido:eventType>
					<xsl:apply-templates select="$findendeRollenN"/>
					<xsl:apply-templates mode="eventPlace" select="$fundorteN"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>