<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 
		Todo: Man könnte bei WorkType oder bei Klassifikation OBjekttyp ne 'Allgemein' zusätzlich angeben.
		Dann hätte man noch Musikinstrument und Fotografie.
	-->

	<xsl:template name="objectWorkTypeWrap">
		<lido:objectWorkTypeWrap>
			<!--xsl:message>
				<xsl:text>OBJEKTTYP: </xsl:text>
				<xsl:value-of select="z:vocabularyReference[@name='ObjCategoryVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
			</xsl:message-->

			<xsl:variable name="archivtypen" select="
			'Archivalie - Akte', 'Archivalie - Einzelblatt', 
			'Archivalie - Slg.-Verzeichnis(Dokumente)', 
			'Archivalie - Sonstiges', 
			'Archivalie - Vorgang'"/>

			<xsl:variable name="objekttyp" select="z:vocabularyReference[
						@name='ObjCategoryVoc'
					]/z:vocabularyReferenceItem/z:formattedValue"/>
			
		
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjTechnicalTermGrp']
					/z:repeatableGroupItem/z:vocabularyReference[
						@name='TechnicalTermVoc'
					]">
					<!--xsl:message>objectWorkType CASE1</xsl:message-->
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

				<!-- 
				Ist das auch ein Sachbegriff? Ja 
				Hat Vorrang als objectWorkType wenn Objekttyp nicht aussagekräftig 
				-->
				<xsl:when test="z:dataField[@name = 'ObjTechnicalTermClb'] and 
					$objekttyp = ('Allgemein', 'Allgemein - ÄMP', 'Behälter', 'Gebrauchsgegenstände', 'Gerät', 'Organisches Material')">
					<!--xsl:message>objectWorkType CASE2</xsl:message-->
					<lido:objectWorkType lido:type="ObjTechnicalTermClb">
						<!-- hardcoded since dataField has no language qualifier in RIA! -->
						<lido:term xml:lang="de">
							<xsl:value-of select="normalize-space(z:dataField[@name = 'ObjTechnicalTermClb']/z:value)"/>
						</lido:term>
					</lido:objectWorkType>
				</xsl:when>

				<!-- Wenn Objekttyp = "Archivalie - Vorgang" etc. -->
				<xsl:when test="$objekttyp = $archivtypen">
					<!--xsl:message>objectWorkType CASE3</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300026685</lido:conceptID>
						<lido:term xml:lang="de">Akte</lido:term>
						<lido:term xml:lang="en">records (documents)</lido:term>
					</lido:objectWorkType>
				</xsl:when>

				<!-- 
					bestimmte aussagekräftige Objekttypen, die sich gut nach AAT mappen lassen 
				-->
				<xsl:when test="func:vocmap-replace-laxer('Objekttyp', $objekttyp, 'aat-label') ne ''">
					<lido:objectWorkType lido:type="Objekttyp-Vocmap">
						<lido:conceptID lido:source="AAT" lido:type="URI">
							<xsl:value-of select="func:vocmap-replace-laxer('Objekttyp', $objekttyp, 'uri')"/>
						</lido:conceptID>
						<lido:term xml:lang="en">
							<xsl:value-of select="func:vocmap-replace-lang('Objekttyp', $objekttyp, 'aat-label', 'en')"/>
						</lido:term>
						<lido:term xml:lang="de">
							<xsl:value-of select="func:vocmap-replace-lang('Objekttyp', $objekttyp, 'aat-label', 'de')"/>
						</lido:term>
					</lido:objectWorkType>
				</xsl:when>

				<!-- Fallback 1: Weitere Objekttypen ohne AAT -->
				<xsl:when test="$objekttyp ne '' and $objekttyp != ('Allgemein','Allgemein - ÄMP', 'Midas-Objekt')">
					<!--xsl:message>objectWorkType CASE14</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<xsl:value-of select="$objekttyp"/>
					</lido:objectWorkType>
					<xsl:message terminate="no">
						<xsl:text>WARNING: Fallback 1 objektworktype! Object </xsl:text>
						<xsl:value-of select="z:systemField[@name='__id']/z:value"/>
					</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="no">
						<!--xsl:text>objectWorkType CASE15</xsl:text-->
						<xsl:text>WARNING: Fallback 2 objektworktype! Object </xsl:text>
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