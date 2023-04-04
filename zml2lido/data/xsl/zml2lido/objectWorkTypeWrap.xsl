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
				<xsl:when test="$objekttyp eq 'Architektur'">
					<!--xsl:message>objectWorkType CASE7</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300263552</lido:conceptID>
						<lido:term xml:lang="en">architecture (object genre)</lido:term>
						<lido:term xml:lang="de">Architektur (Objektgattung)</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Audio'">
					<!--xsl:message>objectWorkType CASE7</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300028633</lido:conceptID>
						<lido:term xml:lang="en">sound recordings</lido:term>
						<lido:term xml:lang="de">Tonträger</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp = ('Bildhauerei', 'Skulptur')">
					<!--xsl:message>objectWorkType CASE11</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300047090</lido:conceptID>
						<lido:term xml:lang="en">sculptures (visual works)</lido:term>
						<lido:term xml:lang="de">Skulptur (visuelles Werk)</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp eq 'Buch'">
					<!--xsl:message>objectWorkType CASE11</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300028051</lido:conceptID>
						<lido:term xml:lang="en">books</lido:term>
						<lido:term xml:lang="de">Buch</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp eq 'Collage'">
					<!--xsl:message>objectWorkType CASE11</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300033963</lido:conceptID>
						<lido:term xml:lang="en">collages (visual works)</lido:term>
						<lido:term xml:lang="de">Collage (zweidimensionales Werk)</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp = ('Druckgraphik', 'Druckgrafik')">
					<!--xsl:message>objectWorkType CASE14</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300041273</lido:conceptID>
						<lido:term xml:lang="en">prints (visual works)</lido:term>
						<lido:term xml:lang="de">Druckgrafik (visuelles Werk)</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp eq 'Film/Video'">
					<!--xsl:message>objectWorkType CASE6</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300263857</lido:conceptID>
						<lido:term xml:lang="en">moving images</lido:term>
						<lido:term xml:lang="de">bewegtes Bild</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Fotografie'">
					<!--xsl:message>objectWorkType CASE5</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300054225</lido:conceptID>
						<lido:term xml:lang="en">photography</lido:term>
						<lido:term xml:lang="de">Fotografie</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Grafik'">
					<!--xsl:message>objectWorkType CASE9</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300264849</lido:conceptID>
						<lido:term xml:lang="en">graphic arts</lido:term>
						<lido:term xml:lang="de">grafische Künste</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp = ('Malerei/Gemälde', 'Malerei')">
					<!--xsl:message>objectWorkType CASE10</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300033618</lido:conceptID>
						<lido:term xml:lang="en">paintings (visual works)</lido:term>
						<lido:term xml:lang="de">Malerei</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp eq 'Musikinstrument'">
					<!--xsl:message>objectWorkType CASE8</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300041620</lido:conceptID>
						<lido:term xml:lang="en">musical instruments</lido:term>
						<lido:term xml:lang="de">Musikinstrument</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Natürliches Objekt'">
					<!--xsl:message>objectWorkType CASE4</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300404125</lido:conceptID>
						<lido:term xml:lang="en">Natural Object</lido:term>
						<lido:term xml:lang="de">Natürliches Objekt</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Numismatik'">
					<!--xsl:message>objectWorkType CASE4</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300054419</lido:conceptID>
						<lido:term xml:lang="en">numismatics</lido:term>
						<lido:term xml:lang="de">Numismatik</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Schmuck'">
					<!--xsl:message>objectWorkType CASE4</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300209286</lido:conceptID>
						<lido:term xml:lang="en">jewelry</lido:term>
						<lido:term xml:lang="de">Schmuck</lido:term>
					</lido:objectWorkType>
				</xsl:when>
				<xsl:when test="$objekttyp eq 'Textdokument'">
					<!--xsl:message>objectWorkType CASE12</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300263751</lido:conceptID>
						<lido:term xml:lang="en">texts (documents)</lido:term>
						<lido:term xml:lang="de">Text (Dokument)</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp = ('Textilkunst', 'Textilie')">
					<!--xsl:message>objectWorkType CASE12</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300386843</lido:conceptID>
						<lido:term xml:lang="en">textile art (visual works)</lido:term>
						<lido:term xml:lang="de">Textilarbeit</lido:term>
					</lido:objectWorkType>
				</xsl:when>				
				<xsl:when test="$objekttyp = 'Zeichnung'">
					<!--xsl:message>objectWorkType CASE13</xsl:message-->
					<lido:objectWorkType lido:type="Objekttyp">
						<lido:conceptID lido:source="AAT" lido:type="URI">http://vocab.getty.edu/aat/300034698</lido:conceptID>
						<lido:term xml:lang="en">drawings by material or technique</lido:term>
						<lido:term xml:lang="de">Zeichnung nach Material oder Technik</lido:term>
					</lido:objectWorkType>
				</xsl:when>				

				<!-- Fallback 1: Weitere Objekttypen -->
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