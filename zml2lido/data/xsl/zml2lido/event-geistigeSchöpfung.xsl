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
		Creation/Geistige Schöpfung: 
		Update 17.12.2021 Geistige Schöpfung soll nur in Ausnahmefällen verwendet werden, 
		von denen wir noch keinen gefunden haben.
    -->
    <xsl:template name="geistigeSchöpfung">
		<xsl:variable name="schöpfendeRollen" select="
		"/>
		<xsl:variable name="perInRole" select="z:moduleReference[@name='ObjPerAssociationRef']/z:moduleReferenceItem[
			z:vocabularyReference/@name = 'RoleVoc' 
			and z:vocabularyReference/z:vocabularyReferenceItem/z:formattedValue = $schöpfendeRollen]"/>

        <xsl:if test="$perInRole">
			<lido:eventSet sortorder="3">
				<lido:displayEvent xml:lang="de">geistige Schöpfung</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00012</lido:conceptID>
						<lido:term xml:lang="en">Creation</lido:term>
						<lido:term xml:lang="de">Geistige Schöpfung</lido:term>
					</lido:eventType>
					<xsl:apply-templates select="$perInRole"/>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>