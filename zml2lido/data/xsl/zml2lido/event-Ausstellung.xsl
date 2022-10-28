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
		Auftrag: Auftraggeber, Münzherr; http://terminology.lido-schema.org/lido00226
    -->
    <xsl:template name="Ausstellung">

		<!-- only if positiv-->
		<xsl:for-each select="z:moduleReference[@name='ObjRegistrarRef']/z:moduleReferenceItem">
			<!--xsl:variable name="registrarV" select="tokenize(z:formattedValue,', ')"/-->
			<xsl:variable name="registrarV" select="z:formattedValue"/>
			<xsl:choose>
				<xsl:when test="substring-after($registrarV, 'Positiv, ')"> 
					<lido:eventSet>
						<lido:displayEvent xml:lang="de">
							<xsl:text>Ausstellung</xsl:text>
						</lido:displayEvent>
						<lido:event>
							<lido:eventType>
								<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00225</lido:conceptID>
								<lido:term xml:lang="de">Ausstellung (Aktivität)</lido:term>
								<lido:term xml:lang="en">Exhibition (Activity)</lido:term>
							</lido:eventType>
							<lido:eventName>
								<lido:appellationValue>
									<xsl:value-of select="substring-after($registrarV, 'Positiv, ')"/>
								</lido:appellationValue>
							</lido:eventName>
						</lido:event>
					</lido:eventSet>
				</xsl:when> 
				<!--xsl:otherwise>
					<xsl:message>
						EXHIBIT IGNORED
						<xsl:value-of select="$value"/>
					</xsl:message>
				</xsl:otherwise>-->
			</xsl:choose>
		</xsl:for-each>

    </xsl:template>
</xsl:stylesheet>