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
		Todo: Man könnte bei WorkType oder bei Klassifikation OBjekttyp ne 'Allgemein' zusätzlich angeben.
		Dann hätte man noch Musikinstrument und Fotografie.
	-->

	<xsl:template name="objectWorkTypeWrap">
		<xsl:choose>
			<xsl:when test="z:repeatableGroup[@name='ObjTechnicalTermGrp']
						/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermVoc']">
				<lido:objectWorkTypeWrap>
					<xsl:apply-templates select="z:repeatableGroup[@name='ObjTechnicalTermGrp']
						/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermVoc']"/>
				</lido:objectWorkTypeWrap>
			</xsl:when>
			<xsl:when test="z:dataField[@name = 'ObjTechnicalTermClb']">
				<lido:objectWorkTypeWrap>
					<lido:objectWorkType lido:type="ObjTechnicalTermClb">
						<!-- hardcoded since dataField has no language qualifier in RIA! -->
						<lido:term xml:lang="de">
							<xsl:value-of select="normalize-space(z:dataField[@name = 'ObjTechnicalTermClb']/z:value)"/>
						</lido:term>
					</lido:objectWorkType>
				</lido:objectWorkTypeWrap>
			</xsl:when>
			<!-- Man könnte Objekttyp nehmen, wenn er nicht "Allgemein" ist -->
			<xsl:when test="z:vocabularyReference[@name='ObjCategoryVoc']/z:formattedValue ne 'Allgemein'">
				<lido:objectWorkTypeWrap>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:term>
							<xsl:value-of select="z:vocabularyReferenceItem[@name='ObjCategoryVoc']/z:formattedValue"/>
						</lido:term>
					</lido:objectWorkType>
				</lido:objectWorkTypeWrap>
			</xsl:when>
			<xsl:otherwise>
				<lido:objectWorkTypeWrap>
					<xsl:choose>
						<xsl:when test="z:vocabularyReference[@name='ObjCategoryVoc']/z:formattedValue eq 'Natürliches Objekt'">
							<lido:conceptID lido:source="RIA:Objekttyp" lido:type="URI">http://vocab.getty.edu/aat/300404125</lido:conceptID>
							<lido:term xml:lang="en">Natural Object</lido:term>
							<lido:term xml:lang="de">Natürliches Objekt</lido:term>
						</xsl:when>
						<xsl:otherwise>
							<lido:conceptID lido:source="RIA:Objekttyp" lido:type="URI">http://www.cidoc-crm.org/cidoc-crm/E22</lido:conceptID>
							<lido:term xml:lang="de">Künstlicher Gegenstand</lido:term>
							<lido:term xml:lang="en">Human-Made Object</lido:term>
						</xsl:otherwise>
					</xsl:choose>
				</lido:objectWorkTypeWrap>
				<xsl:message terminate="no">
					<xsl:text>WARNING: Fallback objektworktype! Object </xsl:text>
					<xsl:value-of select="z:systemField[@name='__id']/z:value"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjTechnicalTermGrp']
		/z:repeatableGroupItem/z:vocabularyReference[@name='TechnicalTermVoc']">
		<lido:objectWorkType lido:type="Sachbegriff">
			<lido:conceptID lido:source="RIA:Sachbegriff" lido:type="local">
				<xsl:value-of select="z:vocabularyReferenceItem/@id"/>
			</lido:conceptID>
			<lido:term>
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue/@language"/>
				</xsl:attribute>
				<xsl:value-of select="normalize-space(z:vocabularyReferenceItem/z:formattedValue)"/>
			</lido:term>
		</lido:objectWorkType>
	</xsl:template>
</xsl:stylesheet>