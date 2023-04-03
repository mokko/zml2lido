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
		<lido:objectWorkTypeWrap>
			<xsl:message>
				<xsl:text>OBJEKTTYP: </xsl:text>
				<xsl:value-of select="z:vocabularyReference[@name='ObjCategoryVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</xsl:message>

			<xsl:variable name="archivtypen" select="
			'Archivalie - Akte', 'Archivalie - Einzelblatt', 
			'Archivalie - Slg.-Verzeichnis(Dokumente)', 
			'Archivalie - Sonstiges', 
			'Archivalie - Vorgang'"/>
		
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjTechnicalTermGrp']
					/z:repeatableGroupItem/z:vocabularyReference[
						@name='TechnicalTermVoc'
					]">
					<xsl:message>objectWorkType CASE1</xsl:message>
					<lido:objectWorkType lido:type="Sachbegriff/TechnicalTermVoc">
						<lido:conceptID lido:source="RIA:Sachbegriff" lido:type="local">
							<xsl:value-of select="z:vocabularyReferenceItem/@id"/>
						</lido:conceptID>
						<lido:term>
							<xsl:if test="z:vocabularyReferenceItem/z:formattedValue/@language ne ''">
								<xsl:attribute name="xml:lang">
									<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue/@language"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="normalize-space(z:vocabularyReferenceItem/z:formattedValue)"/>
						</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<!-- ist das auch Sachbegriff?-->
				<xsl:when test="z:dataField[@name = 'ObjTechnicalTermClb']">
					<xsl:message>objectWorkType CASE2</xsl:message>
					<lido:objectWorkType lido:type="ObjTechnicalTermClb">
						<!-- hardcoded since dataField has no language qualifier in RIA! -->
						<lido:term xml:lang="de">
							<xsl:value-of select="normalize-space(z:dataField[@name = 'ObjTechnicalTermClb']/z:value)"/>
						</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<!-- Wenn Objekttyp = "Archivalie - Vorgang" -->
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
					]/z:vocabularyReferenceItem/z:formattedValue = $archivtypen">
					<xsl:message>objectWorkType CASE3</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300026685</lido:conceptID>
						<lido:term xml:lang="de">Akte</lido:term>
						<lido:term xml:lang="en">records (documents)</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Natürliches Objekt'">
					<xsl:message>objectWorkType CASE4</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300404125</lido:conceptID>
						<lido:term xml:lang="en">Natural Object</lido:term>
						<lido:term xml:lang="de">Natürliches Objekt</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Fotografie'">
					<xsl:message>objectWorkType CASE5</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300054225</lido:conceptID>
						<lido:term xml:lang="en">photography</lido:term>
						<lido:term xml:lang="de">Fotografie</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Film/Video'">
					<xsl:message>objectWorkType CASE6</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300263857</lido:conceptID>
						<lido:term xml:lang="en">moving images</lido:term>
						<lido:term xml:lang="de">bewegtes Bild</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Audio'">
					<xsl:message>objectWorkType CASE7</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300028633</lido:conceptID>
						<lido:term xml:lang="en">sound recordings</lido:term>
						<lido:term xml:lang="de">Tonträger</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Musikinstrument'">
					<xsl:message>objectWorkType CASE8</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300041620</lido:conceptID>
						<lido:term xml:lang="en">musical instruments</lido:term>
						<lido:term xml:lang="de">Musikinstrument</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="z:vocabularyReference[
					@name='ObjCategoryVoc'
				]/z:vocabularyReferenceItem/z:formattedValue eq 'Grafik'">
					<xsl:message>objectWorkType CASE9</xsl:message>
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300264849</lido:conceptID>
						<lido:term xml:lang="en">graphic arts</lido:term>
						<lido:term xml:lang="de">grafische Künste</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="no">
						<xsl:text>objectWorkType CASE10</xsl:text>

						<xsl:text>WARNING: Fallback objektworktype! Object </xsl:text>
						<xsl:value-of select="z:systemField[@name='__id']/z:value"/>
					</xsl:message>
					<lido:objectWorkType>
						<lido:conceptID lido:source="RIA:Objekttyp" lido:type="URI">http://www.cidoc-crm.org/cidoc-crm/E22</lido:conceptID>
						<lido:term xml:lang="de">Künstlicher Gegenstand</lido:term>
						<lido:term xml:lang="en">Human-Made Object</lido:term>
					</lido:objectWorkType>
				</xsl:otherwise>
			</xsl:choose>
		</lido:objectWorkTypeWrap>
	</xsl:template>
</xsl:stylesheet>