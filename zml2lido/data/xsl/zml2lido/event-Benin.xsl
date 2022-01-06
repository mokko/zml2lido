<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- exception for Benin objects: they get an extra event on the request of the DDB -->
    <xsl:template name="Benin">
		<xsl:if test="z:repeatableGroup[
			@name = 'ObjPublicationGrp']/z:repeatableGroupItem[
			z:vocabularyReference[@name = 'TypeVoc' and z:vocabularyReferenceItem/@id = '4460851'] and 
			z:vocabularyReference[@name = 'PublicationVoc' and z:vocabularyReferenceItem/@id = '1810139']
			]">
			<!--xsl:message>BENIN OBJECT</xsl:message-->
			<lido:eventSet>
				<xsl:comment>This is an "artificial" event to identify all Benin objects for 3 Wege Projekt</xsl:comment>
				<lido:displayEvent xml:lang="de">Herstellung</lido:displayEvent>
				<lido:event>
					<lido:eventType>
						<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00007</lido:conceptID>
						<lido:term xml:lang="de">Herstellung</lido:term>
						<lido:term xml:lang="en">Production</lido:term>
					</lido:eventType>
					<lido:eventPlace>
						<lido:place lido:politicalEntity="Benin_Kingdom">
							<lido:placeID lido:type="URI">http://vocab.getty.edu/page/tgn/8711681</lido:placeID>
							<lido:namePlaceSet>
								<lido:appellationValue>Benin</lido:appellationValue>
							</lido:namePlaceSet> 
							<lido:placeClassification>
								<lido:term>kingdom</lido:term>
							</lido:placeClassification>
						</lido:place>
					</lido:eventPlace>
				</lido:event>
			</lido:eventSet>
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>