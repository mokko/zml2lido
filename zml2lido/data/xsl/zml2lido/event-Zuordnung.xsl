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
		<!-- 
		20260308 
		There are records which have a Bereich in the GUI, but no ObjOrgGroupVoc. That is some internal M+ bug.
		-->
		<xsl:variable name="bereich" select="z:vocabularyReference[@name = 'ObjOrgGroupVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
		<xsl:if test="not ($bereich)">
			<xsl:message>
				<xsl:text>WARNING: no OBjOrgGroupVoc BUG in RIA: </xsl:text>
				<xsl:value-of select="z:systemField[@name eq '__orgUnit']/z:value"/>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="bereich2">
			<xsl:choose>
				<xsl:when test="$bereich">
					<xsl:value-of select="$bereich"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<!-- this is meant as a temporary workaround, but zetcom fixes the bug-->
						<xsl:when test="z:systemField[@name eq '__orgUnit']/z:value eq 'KKKlassischeModerne'">KK-Klassische Moderne</xsl:when>
						<xsl:otherwise>
							<xsl:message terminate="yes">ERROR: no OBjOrgGroupVoc BUG in RIA. Please add 
								<xsl:value-of select="z:systemField[@name eq '__orgUnit']/z:value"/> to workaround
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--xsl:message>
			DEBUGGING event-zuordnung.xsl
			<xsl:value-of select="$bereich2"/>
		</xsl:message-->
		<!-- sammlung is a lookup term from vocmap -->
		<xsl:variable name="sammlung" select="func:vocmap-control('Bereich',$bereich2)"/>
		<!--xsl:message>
		DEBUG: Zuordnung.xsl
			<xsl:text>objId: </xsl:text><xsl:value-of select="z:systemField[@name = '__id']/z:value"/>
			<xsl:text>bereich: </xsl:text><xsl:value-of select="$bereich"/>
			<xsl:text>sammlung: </xsl:text><xsl:value-of select="$sammlung"/>
		</xsl:message-->
		<xsl:if test="$sammlung eq ''">
			<xsl:message terminate="yes">
				<xsl:text>objId: </xsl:text>
				<xsl:value-of select="z:systemField[@name = '__id']/z:value"/>
				<xsl:text></xsl:text>
				<xsl:text>ERROR: Leere Zuordnung zu einem kuratierten Bestand.</xsl:text> 
				<xsl:text>Fülle die Lücke in vocmap.xml für den Bereich: </xsl:text>
				<xsl:value-of select="$bereich"/>
			</xsl:message>
		</xsl:if>

		<xsl:if test="$sammlung ne ''">
			<lido:eventSet lido:sortorder="30">
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
		</xsl:if>
    </xsl:template>
</xsl:stylesheet>


