<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="titleWrap">
        <lido:titleWrap>
			<!-- Wenn ein Titel, dann nutze ihn, sonst Sachbegriff--> 
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjObjectTitleGrp']/z:repeatableGroupItem">
					<xsl:apply-templates select="z:repeatableGroup[@name='ObjObjectTitleGrp']/z:repeatableGroupItem"/>
				</xsl:when>
				<xsl:otherwise>
					<!--xsl:message>
						<xsl:text>kein TitelAlpha</xsl:text>
						<xsl:value-of select="z:systemField[@name = '__id']/z:value"/>
					</xsl:message-->
					<lido:titleSet>
						<xsl:attribute name="lido:type">
							<xsl:text>Sachbegriff</xsl:text>
						</xsl:attribute>
						<lido:appellationValue xml:lang="de">
							<xsl:value-of select="normalize-space(z:dataField[@name = 'ObjTechnicalTermClb'])"/>
						</lido:appellationValue>
					</lido:titleSet>
				</xsl:otherwise>
			</xsl:choose>
			<!-- Wenn es einheimische Bezeichnung im Sachbegriff gibt, dann schreibe sie in title\@type="titleLanguageOrigin" -->
			<xsl:apply-templates select="z:repeatableGroup[
				@name = 'ObjTechnicalTermGrp'
				]/z:repeatableGroupItem[
					z:vocabularyReference/z:vocabularyReferenceItem/@id = '4402610'
				]"/>
		</lido:titleWrap>
    </xsl:template>

	<!-- einheimische Bezeichnung aus mpx:Sachbegriff in lido:title-->
	<xsl:template match="z:repeatableGroup[
		@name = 'ObjTechnicalTermGrp'
		]/z:repeatableGroupItem[
			z:vocabularyReference/z:vocabularyReferenceItem/@id = '4402610'
		]">
		<xsl:if test="z:dataField[@name = 'TechnicalTermTxt'] ne ''">
			<xsl:comment>titleLanguageOrigin ist vom CCC-Portal definierter Wert</xsl:comment>
			<lido:titleSet>
				<xsl:attribute name="lido:type">
					<xsl:text>titleLanguageOrigin</xsl:text>
				</xsl:attribute>
				<lido:appellationValue>
					<!-- Sprache wird in RIA nicht qualifiziert -->
					<xsl:value-of select="z:dataField[@name = 'TechnicalTermTxt']"/>
				</lido:appellationValue>
			</lido:titleSet>
		</xsl:if>
	</xsl:template>


	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/
		z:moduleItem/z:repeatableGroup[@name='ObjObjectTitleGrp']/z:repeatableGroupItem">
		<lido:titleSet>
			<xsl:choose>
				<!--Titel vorhanden-->
				<xsl:when test="not (z:dataField[@name = 'TitleTxt']/z:value[normalize-space(.)=''])">
					<!-- TODO: sort for multiple titles missing -->
					<xsl:attribute name="lido:type">
						<xsl:choose>
							<xsl:when test="normalize-space(z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/@name) ne ''">
								<xsl:value-of select="z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/@name"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Titel</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<lido:appellationValue>
						<xsl:attribute name="xml:lang">
							<xsl:choose>
								<xsl:when test="z:vocabularyReference[@name='LanguageVoc']/z:vocabularyReferenceItem/@name ne ''">
									<xsl:value-of select="z:vocabularyReference[@name='LanguageVoc']/z:vocabularyReferenceItem/@name"/>
								</xsl:when>
								<xsl:otherwise>de</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:value-of select="normalize-space(z:dataField[@name = 'TitleTxt']/z:value)"/>
					</lido:appellationValue>
				</xsl:when>
				<xsl:when test="z:dataField[@name = 'TitleTxt']/z:value[normalize-space(.)=''] 
					and ../../z:dataField[@name = 'ObjTechnicalTermClb']">
					<!--xsl:message>
						<xsl:text>kein Titel, aber Sachbegriff</xsl:text>
						<xsl:value-of select="../../z:systemField[@name = '__id']/z:value"/>
					</xsl:message-->
					<xsl:attribute name="lido:type">
						<xsl:text>Sachbegriff</xsl:text>
					</xsl:attribute>
					<lido:appellationValue>
						<xsl:value-of select="normalize-space(../../z:dataField[@name = 'ObjTechnicalTermClb'])"/>
					</lido:appellationValue>
				</xsl:when>
				<xsl:otherwise>
					<!--kein Titel und kein Sachbegriff-->
					<xsl:message terminate="no">
						<xsl:text>!!!KEIN TITEL UND KEIN SACHBEGRIFF!!!</xsl:text> 					
						<xsl:value-of select="../../z:systemField[@name = '__id']/z:value"/>
					</xsl:message>
					<xsl:attribute name="lido:type">
						<xsl:text>kein Titel und kein Sachbegriff</xsl:text>
					</xsl:attribute>
					<lido:appellationValue>
						<xsl:text>kein Titel</xsl:text>
					</lido:appellationValue>
				</xsl:otherwise>
			</xsl:choose>
		</lido:titleSet>
	</xsl:template>
</xsl:stylesheet>